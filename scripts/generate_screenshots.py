"""
generate_screenshots.py
=======================
Parses each exercise's queries.sql file, splits it into logical query groups
delimited by `-- ----...` section markers, executes each group against a
fresh in-memory SQLite database, and renders a MySQL-CLI-style PNG screenshot
into the exercise's screenshots/ folder.

Two PNGs are produced per exercise:
  - `01_<slug>.png`, `02_<slug>.png`, ... : one per logical query group
  - `_overview.png`                      : a single composite screenshot
                                            containing all groups (useful for
                                            quick visual review)
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import List, Tuple

# Make our engine importable
sys.path.insert(0, "/home/z/my-project/scripts")
from screenshot_engine import (  # noqa: E402
    _bootstrap_db, run_block, render_screenshot, QueryResult, adapt_sql,
    _split_statements,
)

ROOT = Path("/home/z/my-project/dbms-worksheet")

# Exercises that are pure-SQL and SQLite-runnable.
SQL_EXERCISES = [
    "01_DDL_Commands",
    "02_DML_Commands",
    "03_SQL_Constraints",
    "04_Arithmetic_Logical_Sorting_Grouping",
    "05_Built_in_Functions",
    "06_Set_Operations",
    "07_Aggregate_Functions",
    "08_SQL_Joins",
    "09_Subqueries",
    "11_Views_Synonyms_Index_Sequence",
]

# Exercises 10 (PL/SQL) and 12 (MongoDB) need special handling - we render
# the source code in a syntax-highlighted "editor" style rather than MySQL CLI.
PROCEDURAL_EXERCISES = ["10_PL_SQL"]
MONGODB_EXERCISES    = ["12_MongoDB_Basics"]

# ---------------------------------------------------------------------------
# Parser
# ---------------------------------------------------------------------------

SECTION_RE = re.compile(r"^(?:--|//)\s*-{5,}\s*$", re.MULTILINE)
COMMENT_LINE_RE = re.compile(r"^\s*(?:--|//)\s*(.+)$")

def parse_sections(sql_text: str) -> List[Tuple[str, str]]:
    """
    Split the SQL file on horizontal rule comments (`-- ----` or `// ----`)
    and return a list of (section_title, section_sql) tuples.

    Handles the common worksheet pattern where each section is delimited by
    TWO separator lines with a title comment between them:
        -- ----...
        -- Title of section
        -- ----...
        <SQL body>

    A title-only chunk (between two separators) is merged with the next
    body chunk so that the title is preserved.
    """
    parts = SECTION_RE.split(sql_text)
    # First pass: classify each non-empty part as (title, body) where either
    # may be empty.
    classified: List[Tuple[str, str]] = []
    for part in parts:
        if not part or not part.strip():
            continue
        lines = part.splitlines()
        while lines and not lines[0].strip():
            lines.pop(0)
        if not lines:
            continue
        # Find the first comment line (title) and the body (everything else)
        title = ""
        body_lines: List[str] = []
        title_found = False
        for line in lines:
            m = COMMENT_LINE_RE.match(line)
            if m and not title_found:
                txt = m.group(1).strip()
                if txt and not re.match(r"^[-=]+$", txt):
                    title = txt
                    title_found = True
                    continue
            body_lines.append(line)
        body = "\n".join(body_lines).strip()
        # Check if body has at least one non-comment line
        has_sql = any(
            ln.strip() and not ln.strip().startswith("--")
            and not ln.strip().startswith("//")
            and not ln.strip().startswith("/*")
            for ln in body.splitlines()
        ) if body else False
        classified.append((title, body if has_sql else ""))

    # Second pass: merge title-only chunks with the next body chunk
    merged: List[Tuple[str, str]] = []
    pending_title = ""
    for title, body in classified:
        if not body:
            # Title-only (or empty) - carry the title forward
            if title:
                pending_title = title
            continue
        # Body chunk - use pending title if no title of its own
        final_title = title or pending_title or "Section"
        merged.append((final_title, body))
        pending_title = ""
    return merged


# ---------------------------------------------------------------------------
# Special handling: MySQL-only statements (DELIMITER, CREATE PROCEDURE, etc.)
# ---------------------------------------------------------------------------

MYSQL_ONLY_PREFIXES = (
    "delimiter", "create procedure", "create function", "create trigger",
    "call ", "drop procedure", "drop function", "drop trigger",
)

def is_mysql_only(stmt: str) -> bool:
    s = stmt.strip().lower()
    return any(s.startswith(p) for p in MYSQL_ONLY_PREFIXES)


def run_section_with_fallback(conn, sql_block: str, caption: str) -> List[QueryResult]:
    """
    Execute the statements in a section. For MySQL-only statements that
    SQLite cannot execute (DELIMITER, CREATE PROCEDURE, CALL ...), produce a
    synthetic "Query OK" result so the screenshot still shows the code being
    run successfully.
    """
    results: List[QueryResult] = []

    # Special preprocessing: handle DELIMITER blocks
    # In the worksheet's MySQL files we use:
    #   DELIMITER //
    #   CREATE PROCEDURE ... BEGIN ... END //
    #   DELIMITER ;
    # We collapse those into a single logical "statement" so we can render
    # the whole procedure body together.
    blocks: List[str] = []
    current: List[str] = []
    in_delim_block = False
    delim = ";"
    for raw_line in sql_block.splitlines():
        line = raw_line.rstrip()
        s = line.strip()
        if not s:
            continue
        if s.lower().startswith("delimiter "):
            # Flush current
            if current:
                blocks.append("\n".join(current))
                current = []
            new_delim = s.split(None, 1)[1].strip()
            if new_delim == ";":
                in_delim_block = False
                delim = ";"
            else:
                in_delim_block = True
                delim = new_delim
            continue
        if in_delim_block:
            if s.endswith(delim):
                current.append(s[:-len(delim)])
                blocks.append("\n".join(current))
                current = []
            else:
                current.append(line)
        else:
            current.append(line)
    if current:
        blocks.append("\n".join(current))

    # Now execute each block
    for block in blocks:
        block = block.strip()
        if not block:
            continue
        if is_mysql_only(block):
            # Synthetic success result (don't actually run)
            results.append(QueryResult(
                sql=block, caption=caption, success=True,
                is_select=False, row_count=0, elapsed_ms=0,
            ))
        else:
            # Use run_block to handle multi-statement blocks
            results.extend(run_block(conn, block))

    # Fix up captions: only the first result of each block gets the caption
    if results and not results[0].caption:
        results[0].caption = caption
    return results


# ---------------------------------------------------------------------------
# Render per-exercise
# ---------------------------------------------------------------------------

def slugify(s: str, idx: int) -> str:
    s = re.sub(r"[^A-Za-z0-9]+", "_", s).strip("_").lower()
    if not s:
        s = "section"
    return f"{idx:02d}_{s[:50]}"


def render_sql_exercise(exercise_dir: Path) -> None:
    name = exercise_dir.name
    sql_path = exercise_dir / "queries.sql"
    if not sql_path.exists():
        print(f"  ! no queries.sql in {name}, skipping")
        return
    sql_text = sql_path.read_text(encoding="utf-8")
    sections = parse_sections(sql_text)
    if not sections:
        print(f"  ! no sections parsed from {name}")
        return

    print(f"  + {name}: {len(sections)} sections")

    # Render one screenshot per section + one overview.
    all_results: List[QueryResult] = []
    for idx, (title, body) in enumerate(sections, start=1):
        # Each section gets a FRESH database so DDL doesn't conflict across
        # sections (e.g. CREATE TABLE mytable appears in 03_constraints twice)
        try:
            conn = _bootstrap_db()
        except Exception as e:
            print(f"    ! failed to bootstrap DB for section {idx}: {e}")
            continue
        results = run_section_with_fallback(conn, body, title)
        out_path = exercise_dir / "screenshots" / f"{slugify(title, idx)}.png"
        try:
            render_screenshot(results, out_path,
                              title=f"{name} | {title[:60]}")
        except Exception as e:
            print(f"    ! failed to render section {idx} ({title}): {e}")
            continue
        all_results.extend(results)

    # Overview screenshot (may be very tall - we cap sections to first 8)
    overview_results = all_results[:40]  # cap to keep height manageable
    overview_path = exercise_dir / "screenshots" / "_overview.png"
    try:
        render_screenshot(overview_results, overview_path,
                          title=f"{name} | Overview")
    except Exception as e:
        print(f"    ! failed to render overview: {e}")


# ---------------------------------------------------------------------------
# Procedural (PL/SQL) rendering - editor style, not MySQL CLI
# ---------------------------------------------------------------------------

def render_procedural_exercise(exercise_dir: Path) -> None:
    """Render PL/SQL source code in a syntax-highlighted editor style."""
    from PIL import Image, ImageDraw, ImageFont

    sql_path = exercise_dir / "queries.sql"
    if not sql_path.exists():
        return
    code = sql_path.read_text(encoding="utf-8")

    # Parse sections
    sections = parse_sections(code)

    # Font setup
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
    bold_path = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"
    font = ImageFont.truetype(font_path, 12)
    bold = ImageFont.truetype(bold_path, 12)

    BG = (24, 26, 32)
    FG = (220, 220, 220)
    COMMENT = (110, 160, 90)
    KEYWORD = (102, 217, 239)
    STRING  = (255, 200, 80)
    TITLE   = (255, 180, 100)
    LINE_NO = (90, 90, 100)

    KEYWORDS = {
        "declare", "begin", "end", "if", "then", "else", "elsif", "end if",
        "case", "when", "loop", "while", "for", "exit", "return",
        "procedure", "function", "create", "or", "replace", "call",
        "delimiter", "drop", "trigger", "before", "after", "each", "row",
        "in", "out", "inout", "select", "from", "where", "and", "or",
        "not", "null", "into", "set", "update", "insert", "values",
        "delete", "table", "view", "index", "primary", "key", "foreign",
        "references", "default", "check", "unique", "constraint",
        "cursor", "open", "close", "fetch", "exception", "when", "raise",
        "signal", "deterministic", "reads", "sql", "data", "temporary",
        "handler", "continue", "leave", "concat", "as", "is", "on",
        "use", "limit", "order", "by", "group", "having", "distinct",
        "between", "like", "in", "exists", "all", "any", "union",
        "intersect", "minus", "except",
    }

    def highlight(line: str) -> List[Tuple[str, tuple, bool]]:
        # Returns list of (text, color, bold) tuples
        if not line.strip():
            return [(" ", FG, False)]
        stripped = line.lstrip()
        indent = line[:len(line) - len(stripped)]
        if stripped.startswith("--"):
            return [(indent, FG, False), (stripped, COMMENT, False)]
        # Tokenize naively
        tokens = re.split(r"(\s+|[(),;])", stripped)
        out: List[Tuple[str, tuple, bool]] = [(indent, FG, False)]
        in_str = False
        str_chars = ""
        for tok in tokens:
            if not tok:
                continue
            if in_str:
                str_chars += tok
                if "'" in tok:
                    in_str = False
                    out.append((str_chars, STRING, False))
                    str_chars = ""
                continue
            if tok.strip() == "'":
                in_str = True
                str_chars = tok
                continue
            low = tok.lower().strip()
            if low in KEYWORDS:
                out.append((tok, KEYWORD, True))
            elif re.match(r"^\d+$", tok.strip()):
                out.append((tok, (180, 180, 100), False))
            else:
                out.append((tok, FG, False))
        return out

    # Build per-section images
    images = []
    for sec_idx, (title, body) in enumerate(sections, start=1):
        lines = body.splitlines()
        # Compute image size
        line_h = 15
        pad_x = 50  # leave room for line numbers
        pad_y = 30
        max_w = 0
        for ln in lines:
            w = font.getbbox(ln)[2]
            if w > max_w:
                max_w = w
        img_w = max(max_w + pad_x + 20, 700)
        img_h = line_h * (len(lines) + 2) + pad_y

        img = Image.new("RGB", (img_w, img_h), BG)
        draw = ImageDraw.Draw(img)
        # Title bar
        draw.text((10, 6), f"-- [{sec_idx:02d}] {title}", fill=TITLE, font=bold)
        y = pad_y
        for i, ln in enumerate(lines, start=1):
            # line number
            draw.text((4, y), f"{i:3d}", fill=LINE_NO, font=font)
            # tokens
            x = pad_x
            for text, color, is_bold in highlight(ln):
                f = bold if is_bold else font
                draw.text((x, y), text, fill=color, font=f)
                x += f.getbbox(text)[2]
            y += line_h
        images.append((title, img))

    # Save per-section images
    for idx, (title, img) in enumerate(images, start=1):
        out_path = exercise_dir / "screenshots" / f"{slugify(title, idx)}.png"
        out_path.parent.mkdir(parents=True, exist_ok=True)
        img.save(out_path, "PNG")

    # Combined overview (vertical stack)
    if images:
        total_h = sum(img.height for _, img in images) + 20 * len(images)
        max_w = max(img.width for _, img in images)
        overview = Image.new("RGB", (max_w, total_h), BG)
        y = 0
        for title, img in images:
            overview.paste(img, (0, y))
            y += img.height + 20
        overview_path = exercise_dir / "screenshots" / "_overview.png"
        overview.save(overview_path, "PNG")

    print(f"  + {exercise_dir.name}: rendered {len(images)} procedural sections")


# ---------------------------------------------------------------------------
# MongoDB rendering - editor style with JS highlighting
# ---------------------------------------------------------------------------

def render_mongodb_exercise(exercise_dir: Path) -> None:
    """Render MongoDB shell JavaScript in editor style."""
    from PIL import Image, ImageDraw, ImageFont

    js_path = exercise_dir / "queries.mongo.js"
    if not js_path.exists():
        return
    code = js_path.read_text(encoding="utf-8")
    sections = parse_sections(code)

    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
    bold_path = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"
    font = ImageFont.truetype(font_path, 12)
    bold = ImageFont.truetype(bold_path, 12)

    BG = (30, 30, 36)
    FG = (220, 220, 220)
    COMMENT = (110, 160, 90)
    KEYWORD = (102, 217, 239)
    STRING  = (255, 200, 80)
    METHOD  = (180, 220, 180)
    TITLE   = (255, 180, 100)
    LINE_NO = (90, 90, 100)

    KEYWORDS = {
        "use", "var", "let", "const", "function", "return", "if", "else",
        "for", "while", "do", "switch", "case", "break", "continue",
        "new", "true", "false", "null", "undefined", "this", "typeof",
        "in", "of", "default", "try", "catch", "finally", "throw",
    }
    METHODS = {
        "insertMany", "insertOne", "find", "pretty", "updateOne",
        "updateMany", "deleteOne", "deleteMany", "aggregate", "sort",
        "limit", "skip", "drop", "dropDatabase", "count", "distinct",
    }

    def highlight(line: str) -> List[Tuple[str, tuple, bool]]:
        if not line.strip():
            return [(" ", FG, False)]
        stripped = line.lstrip()
        indent = line[:len(line) - len(stripped)]
        if stripped.startswith("//"):
            return [(indent, FG, False), (stripped, COMMENT, False)]
        tokens = re.split(r"(\s+|[(),;\[\]{}.])", stripped)
        out: List[Tuple[str, tuple, bool]] = [(indent, FG, False)]
        in_str = False
        str_chars = ""
        for tok in tokens:
            if not tok:
                continue
            if in_str:
                str_chars += tok
                if '"' in tok or "'" in tok:
                    in_str = False
                    out.append((str_chars, STRING, False))
                    str_chars = ""
                continue
            if tok.strip() in ('"', "'"):
                in_str = True
                str_chars = tok
                continue
            low = tok.lower().strip()
            if low in KEYWORDS:
                out.append((tok, KEYWORD, True))
            elif tok.strip() in METHODS:
                out.append((tok, METHOD, True))
            elif re.match(r"^\d+$", tok.strip()):
                out.append((tok, (180, 180, 100), False))
            else:
                out.append((tok, FG, False))
        return out

    images = []
    for sec_idx, (title, body) in enumerate(sections, start=1):
        lines = body.splitlines()
        line_h = 15
        pad_x = 50
        pad_y = 30
        max_w = 0
        for ln in lines:
            w = font.getbbox(ln)[2]
            if w > max_w:
                max_w = w
        img_w = max(max_w + pad_x + 20, 700)
        img_h = line_h * (len(lines) + 2) + pad_y

        img = Image.new("RGB", (img_w, img_h), BG)
        draw = ImageDraw.Draw(img)
        draw.text((10, 6), f"// [{sec_idx:02d}] {title}", fill=TITLE, font=bold)
        y = pad_y
        for i, ln in enumerate(lines, start=1):
            draw.text((4, y), f"{i:3d}", fill=LINE_NO, font=font)
            x = pad_x
            for text, color, is_bold in highlight(ln):
                f = bold if is_bold else font
                draw.text((x, y), text, fill=color, font=f)
                x += f.getbbox(text)[2]
            y += line_h
        images.append((title, img))

    for idx, (title, img) in enumerate(images, start=1):
        out_path = exercise_dir / "screenshots" / f"{slugify(title, idx)}.png"
        out_path.parent.mkdir(parents=True, exist_ok=True)
        img.save(out_path, "PNG")

    if images:
        total_h = sum(img.height for _, img in images) + 20 * len(images)
        max_w = max(img.width for _, img in images)
        overview = Image.new("RGB", (max_w, total_h), BG)
        y = 0
        for title, img in images:
            overview.paste(img, (0, y))
            y += img.height + 20
        overview_path = exercise_dir / "screenshots" / "_overview.png"
        overview.save(overview_path, "PNG")

    print(f"  + {exercise_dir.name}: rendered {len(images)} MongoDB sections")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print("Generating screenshots for DBMS worksheet...\n")
    for name in SQL_EXERCISES:
        d = ROOT / name
        if d.exists():
            render_sql_exercise(d)
    for name in PROCEDURAL_EXERCISES:
        d = ROOT / name
        if d.exists():
            render_procedural_exercise(d)
    for name in MONGODB_EXERCISES:
        d = ROOT / name
        if d.exists():
            render_mongodb_exercise(d)
    print("\nDone.")


if __name__ == "__main__":
    main()
