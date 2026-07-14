"""
screenshot_engine.py
====================
Executes a list of (caption, sql) pairs against an in-memory SQLite database
that has been bootstrapped from the MySQL schema, and renders each query +
its result set as a MySQL-CLI-style PNG screenshot.

Why SQLite? No MySQL server is available in this sandbox. SQLite can execute
~95% of the worksheet's queries unmodified. The few MySQL-isms are
auto-adapted by `adapt_sql()` so we still produce *real* result sets, then
we render them to look exactly like the MySQL CLI output the student would
see in a real lab.
"""
from __future__ import annotations

import os
import re
import sqlite3
import textwrap
from dataclasses import dataclass, field
from datetime import date, datetime
from io import BytesIO
from pathlib import Path
from typing import List, Tuple, Optional

from PIL import Image, ImageDraw, ImageFont

# ---------------------------------------------------------------------------
# Font discovery (works in the sandbox)
# ---------------------------------------------------------------------------
FONT_CANDIDATES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf",
]

def _load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = FONT_CANDIDATES[2:] if not bold else FONT_CANDIDATES[1::2]
    candidates = FONT_CANDIDATES[:]
    if bold:
        candidates = [
            "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf",
        ] + [c for c in candidates if "Bold" not in c]
    else:
        candidates = [
            "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf",
        ] + candidates
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()

# ---------------------------------------------------------------------------
# MySQL -> SQLite SQL adapter
# ---------------------------------------------------------------------------

def adapt_sql(sql: str) -> str:
    """Translate MySQL-specific syntax to SQLite-compatible syntax."""
    s = sql.strip().rstrip(";")

    # Strip MySQL storage engine / charset suffixes
    s = re.sub(r"ENGINE\s*=\s*\w+", "", s, flags=re.I)
    s = re.sub(r"DEFAULT\s+CHARSET\s*=\s*\w+", "", s, flags=re.I)
    s = re.sub(r"CHARACTER\s+SET\s+\w+", "", s, flags=re.I)
    s = re.sub(r"COLLATE\s+\w+", "", s, flags=re.I)
    s = re.sub(r"AUTO_INCREMENT", "AUTOINCREMENT", s, flags=re.I)

    # int(2), varchar2(25), number(8,2) etc. - strip (n) for non-numeric types
    s = re.sub(r"\bVARCHAR2\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "VARCHAR", s, flags=re.I)
    s = re.sub(r"\bNUMBER\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "NUMERIC", s, flags=re.I)
    s = re.sub(r"\bINT\s*\(\s*\d+\s*\)", "INTEGER", s, flags=re.I)
    s = re.sub(r"\bTINYINT\s*\(\s*\d+\s*\)", "INTEGER", s, flags=re.I)
    s = re.sub(r"\bSMALLINT\s*\(\s*\d+\s*\)", "INTEGER", s, flags=re.I)
    s = re.sub(r"\bBIGINT\s*\(\s*\d+\s*\)", "INTEGER", s, flags=re.I)
    s = re.sub(r"\bFLOAT\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "REAL", s, flags=re.I)
    s = re.sub(r"\bDOUBLE\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "REAL", s, flags=re.I)
    s = re.sub(r"\bDECIMAL\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "NUMERIC", s, flags=re.I)
    s = re.sub(r"\bCHAR\s*\(\s*\d+\s*\)", "TEXT", s, flags=re.I)
    s = re.sub(r"\bCLOB\b", "TEXT", s, flags=re.I)
    s = re.sub(r"\bBYTE\b", "", s, flags=re.I)  # "VARCHAR2(4 BYTE)" -> already handled

    # SQLite uses `MODIFY COLUMN` differently; for our purposes the worksheet's
    # ALTER statements are demonstrations - we translate to ones that execute.
    # "ALTER TABLE x MODIFY col TYPE" -> "ALTER TABLE x MODIFY col TYPE" not valid in SQLite,
    # but we let it fail gracefully and still display the output.

    # Rename: "RENAME TABLE a TO b" -> "ALTER TABLE a RENAME TO b"
    s = re.sub(r"^\s*RENAME\s+TABLE\s+(\w+)\s+TO\s+(\w+)\s*$",
               r"ALTER TABLE \1 RENAME TO \2", s, flags=re.I | re.M)

    # "ALTER TABLE t ADD COLUMN(c1 type)" -> "ALTER TABLE t ADD COLUMN c1 type"
    s = re.sub(r"ADD\s+COLUMN\s*\(\s*(\w+)\s+([^)]+)\s*\)",
               r"ADD COLUMN \1 \2", s, flags=re.I)

    # "ALTER TABLE t ADD \`col\` type AFTER other" -> just add (SQLite doesn't support AFTER)
    s = re.sub(r"ADD\s+`([^`]+)`\s+(\w+(?:\(\d+\))?)\s+AFTER\s+\w+",
               r"ADD COLUMN \1 \2", s, flags=re.I)
    # "ALTER TABLE t MODIFY COLUMN c TYPE" -> SQLite doesn't support; we'll skip exec
    # "ALTER TABLE t ALTER COLUMN c SET DEFAULT 'x'" -> skip (we'll just note in output)

    # backtick -> double quote for SQLite compatibility
    s = re.sub(r"`", '"', s)

    # TRUNCATE TABLE t -> DELETE FROM t
    s = re.sub(r"^\s*TRUNCATE\s+TABLE\s+(\w+)", r"DELETE FROM \1", s, flags=re.I | re.M)

    # SYSDATE -> CURRENT_DATE
    s = re.sub(r"\bSYSDATE\b", "CURRENT_DATE", s, flags=re.I)

    # TO_DATE('feb 3,1999','mon, dd ,yyyy') -> date('1999-02-03')
    def _to_date(m):
        date_str = m.group(1)
        # Try a few formats
        for fmt in ("%b %d, %Y", "%Y-%m-%d", "%d-%b-%Y", "%b %d %Y"):
            try:
                return f"date('{datetime.strptime(date_str, fmt).strftime('%Y-%m-%d')}')"
            except Exception:
                continue
        return f"date('{date_str}')"
    s = re.sub(r"TO_DATE\s*\(\s*'([^']+)'\s*,\s*'[^']+'\s*\)", _to_date, s, flags=re.I)

    # TO_CHAR(x, fmt) -> CAST(x AS TEXT)
    s = re.sub(r"TO_CHAR\s*\(([^,]+),\s*'[^']+'\s*\)", r"CAST(\1 AS TEXT)", s, flags=re.I)

    # CONCAT(a, b, ...) -> a || b || ...
    def _concat(m):
        args = [a.strip() for a in m.group(1).split(",")]
        return "(" + " || ".join(args) + ")"
    s = re.sub(r"CONCAT\s*\(([^()]+)\)", _concat, s, flags=re.I)

    # NVL(a, b) -> IFNULL(a, b)
    s = re.sub(r"\bNVL\s*\(", "IFNULL(", s, flags=re.I)

    # MINUS -> EXCEPT
    s = re.sub(r"\bMINUS\b", "EXCEPT", s, flags=re.I)

    # Oracle string concat || works in SQLite already.

    # "LIMIT n, m" -> already supported by SQLite (offset, count)

    # Now() / CURRENT_TIMESTAMP are fine.

    # Strip comments
    s = re.sub(r"--.*$", "", s, flags=re.M)
    s = re.sub(r"/\*.*?\*/", "", s, flags=re.S)

    return s.strip()

# ---------------------------------------------------------------------------
# Database bootstrap
# ---------------------------------------------------------------------------

SCHEMA_FILE = "/home/z/my-project/dbms-worksheet/schema/00_setup_database.sql"

def _bootstrap_db() -> sqlite3.Connection:
    """Return an in-memory SQLite DB with the worksheet schema + data loaded."""
    conn = sqlite3.connect(":memory:")
    conn.row_factory = None  # plain tuples
    # Enable foreign keys (off by default in SQLite)
    conn.execute("PRAGMA foreign_keys = ON;")
    with open(SCHEMA_FILE, "r", encoding="utf-8") as f:
        raw = f.read()
    # Strip MySQL-only declarations that SQLite can't parse
    raw = re.sub(r"DROP\s+DATABASE[^\n]*", "", raw, flags=re.I)
    raw = re.sub(r"CREATE\s+DATABASE[^\n]*", "", raw, flags=re.I)
    raw = re.sub(r"USE\s+\w+", "", raw, flags=re.I)
    raw = re.sub(r"ENGINE\s*=\s*\w+", "", raw, flags=re.I)
    raw = re.sub(r"DEFAULT\s+CHARSET\s*=\s*\w+", "", raw, flags=re.I)
    raw = re.sub(r"CHARACTER\s+SET\s+\w+", "", raw, flags=re.I)
    raw = re.sub(r"COLLATE\s+\w+", "", raw, flags=re.I)
    raw = re.sub(r"\bVARCHAR2\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "VARCHAR", raw, flags=re.I)
    raw = re.sub(r"\bNUMBER\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "NUMERIC", raw, flags=re.I)
    raw = re.sub(r"\bINT\s*\(\s*\d+\s*\)", "INTEGER", raw, flags=re.I)
    raw = re.sub(r"\bTINYINT\s*\(\s*\d+\s*\)", "INTEGER", raw, flags=re.I)
    raw = re.sub(r"\bSMALLINT\s*\(\s*\d+\s*\)", "INTEGER", raw, flags=re.I)
    raw = re.sub(r"\bBIGINT\s*\(\s*\d+\s*\)", "INTEGER", raw, flags=re.I)
    raw = re.sub(r"\bFLOAT\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "REAL", raw, flags=re.I)
    raw = re.sub(r"\bDECIMAL\s*\(\s*\d+\s*(,\s*\d+\s*)?\)", "NUMERIC", raw, flags=re.I)
    raw = re.sub(r"\bCHAR\s*\(\s*\d+\s*\)", "TEXT", raw, flags=re.I)
    raw = re.sub(r"AUTO_INCREMENT", "AUTOINCREMENT", raw, flags=re.I)
    raw = raw.replace("`", '"')
    # Split on semicolons (string-literal aware); strip leading comments per stmt
    raw_statements = _split_statements(raw)
    cur = conn.cursor()
    for stmt in raw_statements:
        # Strip full-line comments from the start of the statement
        lines = stmt.splitlines()
        while lines and (not lines[0].strip()
                         or lines[0].strip().startswith("--")
                         or lines[0].strip().startswith("/*")):
            lines.pop(0)
        cleaned = "\n".join(lines).strip()
        if not cleaned:
            continue
        if re.match(r"^\s*PRAGMA\b", cleaned, flags=re.I):
            continue
        try:
            cur.execute(cleaned)
        except sqlite3.OperationalError as e:
            raise RuntimeError(
                f"Failed to execute statement:\n{cleaned[:500]}\nError: {e}"
            )
    conn.commit()
    return conn

# ---------------------------------------------------------------------------
# Query execution
# ---------------------------------------------------------------------------

@dataclass
class QueryResult:
    sql: str
    caption: str
    success: bool = True
    columns: List[str] = field(default_factory=list)
    rows: List[Tuple] = field(default_factory=list)
    row_count: int = 0
    elapsed_ms: int = 0
    error: Optional[str] = None
    is_select: bool = True

def execute_query(conn: sqlite3.Connection, sql: str, caption: str = "") -> QueryResult:
    """Execute a single SQL statement and return its result."""
    adapted = adapt_sql(sql)
    cur = conn.cursor()
    start = datetime.now()
    is_select = bool(re.match(r"^\s*(SELECT|WITH|SHOW|DESC|EXPLAIN|PRAGMA)\b",
                              adapted, flags=re.I))
    try:
        cur.execute(adapted)
        if is_select:
            columns = [d[0] for d in cur.description] if cur.description else []
            rows = cur.fetchall()
            elapsed = (datetime.now() - start).microseconds // 1000
            return QueryResult(
                sql=sql, caption=caption, success=True,
                columns=columns, rows=list(rows),
                row_count=len(rows), elapsed_ms=elapsed, is_select=True,
            )
        else:
            conn.commit()
            row_count = cur.rowcount if cur.rowcount >= 0 else 0
            elapsed = (datetime.now() - start).microseconds // 1000
            return QueryResult(
                sql=sql, caption=caption, success=True,
                row_count=row_count, elapsed_ms=elapsed, is_select=False,
            )
    except Exception as e:
        elapsed = (datetime.now() - start).microseconds // 1000
        return QueryResult(
            sql=sql, caption=caption, success=False,
            error=str(e), elapsed_ms=elapsed, is_select=is_select,
        )

# ---------------------------------------------------------------------------
# Screenshot rendering (MySQL CLI style)
# ---------------------------------------------------------------------------

# Colors approximating a dark terminal
BG_COLOR     = (30, 30, 36)
FG_COLOR     = (220, 220, 220)
PROMPT_COLOR = (102, 217, 239)
HEADER_SEP   = (110, 110, 120)
META_COLOR   = (170, 170, 170)
ERROR_COLOR  = (255, 120, 120)
TITLE_COLOR  = (255, 200, 80)
CAPTION_COLOR= (200, 200, 220)

CHAR_W = 8   # approximate (matches 14pt DejaVu Sans Mono)
LINE_H = 18
PAD_X  = 16
PAD_Y  = 14

def _format_cell(val) -> str:
    if val is None:
        return "NULL"
    if isinstance(val, float):
        # MySQL prints 24000.00 for DECIMAL(8,2)
        if val == int(val):
            return f"{val:.2f}"
        return f"{val:.4f}".rstrip("0").rstrip(".")
    if isinstance(val, (int,)):
        return str(val)
    if isinstance(val, (date, datetime)):
        return val.strftime("%Y-%m-%d")
    return str(val)

def _measure_text(text: str, font: ImageFont.FreeTypeFont) -> int:
    bbox = font.getbbox(text)
    return bbox[2] - bbox[0]

def _wrap_sql(sql: str, max_width_chars: int = 100) -> List[str]:
    """Wrap a SQL statement for terminal display. Preserves line breaks."""
    out = []
    for raw_line in sql.splitlines() or [sql]:
        line = raw_line.rstrip()
        if not line:
            out.append("")
            continue
        if len(line) <= max_width_chars:
            out.append(line)
            continue
        # Use textwrap with sensible break points
        wrapped = textwrap.wrap(line, width=max_width_chars,
                                break_long_words=False,
                                break_on_hyphens=False)
        out.extend(wrapped if wrapped else [""])
    return out

def render_screenshot(results: List[QueryResult], out_path: Path,
                      title: str = "MySQL Console",
                      max_width_chars: int = 120) -> Path:
    """Render one or more QueryResults as a single PNG screenshot."""
    font = _load_font(14)
    bold_font = _load_font(14, bold=True)

    # Build the "screen lines" as a list of (text, color, bold) tuples.
    screen_lines: List[Tuple[str, tuple, bool]] = []

    # Title bar
    screen_lines.append((f"┌─ {title} ───────────────────────────────────────",
                         TITLE_COLOR, True))
    screen_lines.append((f"│ mysql -u root -p dbms_worksheet", META_COLOR, False))
    screen_lines.append(("└────────────────────────────────────────────────",
                         TITLE_COLOR, True))
    screen_lines.append(("Type 'help;' or '\\h' for help. Type '\\c' to clear the current input statement.",
                         META_COLOR, False))
    screen_lines.append(("mysql> USE dbms_worksheet;", FG_COLOR, False))
    screen_lines.append(("Database changed", META_COLOR, False))
    screen_lines.append(("", FG_COLOR, False))

    for r in results:
        # Caption (comment-like)
        if r.caption:
            screen_lines.append((f"-- {r.caption}", CAPTION_COLOR, False))

        # SQL lines
        sql_lines = _wrap_sql(r.sql, max_width_chars=max_width_chars - 7)
        for i, ln in enumerate(sql_lines):
            prompt = "mysql> " if i == 0 else "    -> "
            color = PROMPT_COLOR if i == 0 else FG_COLOR
            screen_lines.append((prompt + ln, color, False))

        # Result
        if not r.success:
            screen_lines.append((f"ERROR {r.elapsed_ms}ms: {r.error}",
                                 ERROR_COLOR, True))
            screen_lines.append(("", FG_COLOR, False))
            continue

        if r.is_select:
            if not r.columns:
                screen_lines.append(("Empty set", META_COLOR, False))
            else:
                # Compute column widths
                str_rows = [[_format_cell(c) for c in row] for row in r.rows]
                widths = [len(c) for c in r.columns]
                for row in str_rows:
                    for i, cell in enumerate(row):
                        if len(cell) > widths[i]:
                            widths[i] = len(cell)
                widths = [max(w, 2) for w in widths]

                # Build border
                def make_border(left, mid, right, fill):
                    return left + mid.join(fill * (w + 2) for w in widths) + right
                top    = make_border("+", "+", "+", "-")
                bottom = top
                mid    = make_border("+", "+", "+", "-")

                # Header row
                header_cells = [f" {c:<{widths[i]}} " for i, c in enumerate(r.columns)]
                header_line = "|" + "|".join(header_cells) + "|"

                screen_lines.append((top, HEADER_SEP, False))
                screen_lines.append((header_line, HEADER_SEP, True))
                screen_lines.append((mid, HEADER_SEP, False))
                for row in str_rows:
                    cells = []
                    for i, cell in enumerate(row):
                        # Right-align numbers, left-align text
                        if r.columns and _is_numeric_col(r.columns[i], str_rows, i):
                            cells.append(f" {cell:>{widths[i]}} ")
                        else:
                            cells.append(f" {cell:<{widths[i]}} ")
                    screen_lines.append(("|" + "|".join(cells) + "|",
                                         FG_COLOR, False))
                screen_lines.append((bottom, HEADER_SEP, False))
                if r.row_count == 0:
                    screen_lines.append(("Empty set", META_COLOR, False))
                else:
                    screen_lines.append((f"{r.row_count} row{'s' if r.row_count != 1 else ''} in set ({r.elapsed_ms/1000:.2f} sec)",
                                         META_COLOR, False))
        else:
            screen_lines.append((f"Query OK, {r.row_count} row{'s' if r.row_count != 1 else ''} affected ({r.elapsed_ms/1000:.2f} sec)",
                                 META_COLOR, False))
        screen_lines.append(("", FG_COLOR, False))

    # Final prompt
    screen_lines.append(("mysql> exit", PROMPT_COLOR, False))
    screen_lines.append(("Bye", META_COLOR, False))

    # Compute image dimensions
    max_text_width = 0
    for text, _, _ in screen_lines:
        w = _measure_text(text, font)
        if w > max_text_width:
            max_text_width = w

    img_w = max_text_width + 2 * PAD_X
    img_h = LINE_H * len(screen_lines) + 2 * PAD_Y

    # Enforce a sensible minimum / maximum
    img_w = max(img_w, 700)
    img_w = min(img_w, 2000)

    img = Image.new("RGB", (img_w, img_h), BG_COLOR)
    draw = ImageDraw.Draw(img)
    y = PAD_Y
    for text, color, bold in screen_lines:
        fnt = bold_font if bold else font
        draw.text((PAD_X, y), text, fill=color, font=fnt)
        y += LINE_H

    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path, "PNG")
    return out_path


def _is_numeric_col(col_name: str, str_rows: List[List[str]], idx: int) -> bool:
    """Heuristic: a column is numeric if all non-NULL values look numeric."""
    numeric_keywords = {
        "salary", "employee_id", "department_id", "manager_id", "location_id",
        "min_salary", "max_salary", "lowest_salary", "highest_salary",
        "dept_id", "order_id", "order_num", "customerid", "age", "id", "no",
        "qty", "price", "rating", "experience", "basic", "allowance",
        "consultation", "salaryid", "count", "avg", "sum", "min", "max",
        "total", "average", "minimum", "maximum", "current_value",
        "replacement_value", "totalvalue", "doctorcount", "voterid",
        "s_no", "population", "rows_cnt", "rowcount",
    }
    if col_name.lower().replace(" ", "_") in numeric_keywords:
        return True
    if any(k in col_name.lower() for k in ("salary", "_id", "count", "avg",
                                           "sum", "min", "max", "total",
                                           "qty", "price", "year", "no")):
        return True
    # Check by value
    numeric_count = 0
    total = 0
    for row in str_rows:
        if idx < len(row):
            val = row[idx]
            if val in ("NULL", ""):
                continue
            total += 1
            try:
                float(val.replace(",", ""))
                numeric_count += 1
            except Exception:
                pass
    return total > 0 and numeric_count / total > 0.7

# ---------------------------------------------------------------------------
# Higher-level helpers
# ---------------------------------------------------------------------------

def run_block(conn: sqlite3.Connection, block_sql: str) -> List[QueryResult]:
    """
    Execute a SQL block that may contain multiple statements separated by ';'.
    Returns a QueryResult for each statement. Statements starting with '--'
    or '/*' are skipped; the comment line above a statement is preserved as
    part of the previous QueryResult.caption if applicable.
    """
    # Split into statements, preserving comments
    statements = []
    current_lines = []
    last_comment = ""
    for raw_line in block_sql.splitlines():
        line = raw_line.rstrip()
        if not line.strip():
            continue
        stripped = line.strip()
        if stripped.startswith("--"):
            # Comment - flush current statement if any
            if current_lines:
                statements.append((last_comment, " ".join(current_lines)))
                current_lines = []
                last_comment = ""
            last_comment = stripped.lstrip("-").strip()
            continue
        current_lines.append(line)
    if current_lines:
        statements.append((last_comment, " ".join(current_lines)))

    results = []
    for caption, stmt in statements:
        # Some statements are MySQL-only (ALTER ... MODIFY, ALTER ... SET DEFAULT, etc.)
        # Try to execute; on failure, return a stub result.
        if not stmt.strip():
            continue
        # Split on ; if multiple in this stmt
        for sub in [s.strip() for s in _split_statements(stmt) if s.strip()]:
            results.append(execute_query(conn, sub, caption=caption))
    return results


def _split_statements(sql: str) -> List[str]:
    """Naive statement splitter on ';' (no string-literal awareness beyond simple cases)."""
    out = []
    buf = []
    in_str = False
    quote = ""
    for ch in sql:
        if not in_str and ch in ("'", '"', "`"):
            in_str = True
            quote = ch
            buf.append(ch)
        elif in_str and ch == quote:
            in_str = False
            quote = ""
            buf.append(ch)
        elif ch == ";" and not in_str:
            out.append("".join(buf))
            buf = []
        else:
            buf.append(ch)
    if buf:
        out.append("".join(buf))
    return out


def render_exercise(query_blocks: List[Tuple[str, str]], out_path: Path,
                    title: str = "MySQL Console") -> Path:
    """
    Run multiple SQL blocks against a fresh DB and render all into one PNG.
    `query_blocks` is a list of (caption, sql_block) tuples.
    """
    conn = _bootstrap_db()
    all_results: List[QueryResult] = []
    for caption, sql in query_blocks:
        results = run_block(conn, sql)
        # Attach caption to first result if it has no caption
        if results and caption and not results[0].caption:
            results[0].caption = caption
        all_results.extend(results)
    return render_screenshot(all_results, out_path, title=title)


# Quick CLI for manual testing
if __name__ == "__main__":
    import sys
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/test_shot.png")
    title = sys.argv[2] if len(sys.argv) > 2 else "MySQL Console"
    blocks = [
        ("Show all employees in department 90",
         "SELECT employee_id, first_name, last_name, salary FROM employees WHERE department_id = 90;"),
        ("Count of departments",
         "SELECT COUNT(*) AS total_depts FROM departments;"),
    ]
    p = render_exercise(blocks, out, title=title)
    print(f"Wrote {p}")
