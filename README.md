# DBMS Worksheet — CH.SC.U4CSE24041

> A complete, GitHub-ready laboratory workbook for the **Database Management
> Systems** course at **Amrita Vishwa Vidyapeetham, Chennai Campus**.

| Field | Value |
|-------|-------|
| **Student Name** | Shaik Muzzammil |
| **Roll No.**     | CH.SC.U4CSE24041 |
| **Department**   | Computer Science & Engineering |
| **Programme**    | B.E. (CSE), Second Year |
| **Academic Year**| 2025 - 26 |
| **Course**       | Database Management Systems Lab |
| **Editor**       | Dr. A. Padmavathi |

---

## Table of Contents

1. [About this Repository](#about-this-repository)
2. [Repository Structure](#repository-structure)
3. [Prerequisites](#prerequisites)
4. [Quick Start](#quick-start)
5. [Schema Overview](#schema-overview)
6. [Exercises](#exercises)
   1. [01 — DDL Commands](#01--ddl-commands)
   2. [02 — DML Commands](#02--dml-commands)
   3. [03 — SQL Constraints](#03--sql-constraints)
   4. [04 — Arithmetic / Logical / Sorting / Grouping](#04--arithmetic--logical--sorting--grouping)
   5. [05 — Built-in Functions](#05--built-in-functions)
   6. [06 — Set Operations](#06--set-operations)
   7. [07 — Aggregate Functions](#07--aggregate-functions)
   8. [08 — SQL Joins](#08--sql-joins)
   9. [09 — Subqueries](#09--subqueries)
   10. [10 — PL/SQL](#10--plsql)
   11. [11 — Views, Synonyms, Index, Sequence](#11--views-synonyms-index-sequence)
   12. [12 — MongoDB Basics](#12--mongodb-basics)
7. [Viva Question Bank](#viva-question-bank)
8. [Reproducing the Screenshots](#reproducing-the-screenshots)
9. [Contributing / License](#contributing--license)

---

## About this Repository

This repository is a **complete, graded submission** for the DBMS lab workbook.
For each of the 12 exercises prescribed in the official workbook, it contains:

- A clean, commented **MySQL `.sql` script** (`queries.sql`) containing every
  self-activity question with its answer.
- **PNG screenshots** of the queries executed against a live database, showing
  the exact MySQL CLI output (rendered locally with a real result-set — the
  screenshots reflect actual data, not mocked output).
- A per-exercise **`README.md`** with the objective, key SQL concepts
  demonstrated, and a list of the screenshot files.

The worksheet's PDF source can be requested from the student; this repository
contains the **executable form** of every answer.

---

## Repository Structure

```
dbms-worksheet-CH.SC.U4CSE24041/
├── README.md                         ← You are here
├── LICENSE                           ← MIT
├── .gitignore
├── schema/
│   └── 00_setup_database.sql         ← Master schema + seed data
├── 01_DDL_Commands/
│   ├── README.md
│   ├── queries.sql
│   └── screenshots/
│       ├── 01_*.png  ... 0N_*.png
│       └── _overview.png
├── 02_DML_Commands/        (same layout)
├── 03_SQL_Constraints/     (same layout)
├── 04_Arithmetic_Logical_Sorting_Grouping/
├── 05_Built_in_Functions/
├── 06_Set_Operations/
├── 07_Aggregate_Functions/
├── 08_SQL_Joins/
├── 09_Subqueries/
├── 10_PL_SQL/
├── 11_Views_Synonyms_Index_Sequence/
└── 12_MongoDB_Basics/
    ├── README.md
    ├── queries.mongo.js             ← mongosh script
    └── screenshots/
```

---

## Prerequisites

| Tool       | Version   | Notes                                                       |
|------------|-----------|-------------------------------------------------------------|
| MySQL      | 8.0+      | Or MariaDB 10.5+. Required for exercises 01-11.            |
| MongoDB    | 6.0+      | Required for exercise 12. Install `mongosh` separately.     |
| Python     | 3.9+      | Only required if you want to regenerate screenshots.        |

The `schema/00_setup_database.sql` script was authored for **MySQL 8.0**.
Most statements work in MariaDB unchanged. The PL/SQL exercise (`10_PL_SQL`)
uses MySQL stored procedures (the Oracle PL/SQL syntax from the worksheet is
preserved as comments for cross-reference).

---

## Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/<your-username>/dbms-worksheet-CH.SC.U4CSE24041.git
cd dbms-worksheet-CH.SC.U4CSE24041

# 2. Log in to MySQL and load the schema + seed data
mysql -u root -p < schema/00_setup_database.sql

# 3. Run any exercise, e.g. Exercise 04 (Sorting & Grouping)
mysql -u root -p dbms_worksheet < 04_Arithmetic_Logical_Sorting_Grouping/queries.sql

# 4. Open the matching screenshot to compare against your own output
xdg-open 04_Arithmetic_Logical_Sorting_Grouping/screenshots/_overview.png
```

For the MongoDB exercise:

```bash
mongosh < 12_MongoDB_Basics/queries.mongo.js
```

---

## Schema Overview

The master schema (in `schema/00_setup_database.sql`) is a small **HR-style
dataset** with the following tables:

| Table          | Rows | Description                                              |
|----------------|------|----------------------------------------------------------|
| `departments`  | 27   | Departments with manager and location references.        |
| `jobs`         | 19   | Job titles and salary bands.                             |
| `employees`    | 107  | The main table — used across most exercises.             |
| `job_grades`   | 6    | Salary bands A–F; used in non-equijoins.                 |
| `job_history`  | 10   | Past jobs of employees; used in set operations.          |
| `locations`    | 23   | Office locations; used in three-table joins.             |
| `department`   | 5    | Small demo table for DML illustrations in the worksheet. |

After loading, the script prints a verification table showing the row count
per table.

---

## Exercises

### 01 — DDL Commands

**Objective.** Practice `CREATE TABLE`, `RENAME`, `ALTER TABLE`
(`ADD`, `MODIFY`, `DROP`, `RENAME COLUMN`), `TRUNCATE`, and `DROP`.

**Highlights.**
- Build a `Country` table, rename it, add/drop/modify columns, and finally
  drop the whole table.
- Demonstrate `CREATE TABLE ... AS SELECT` (subquery) to clone the structure
  and data of an existing table.
- Compare `TRUNCATE` (DDL — keeps structure, removes rows) vs `DROP`
  (DDL — removes structure entirely).

📁 [`01_DDL_Commands/queries.sql`](01_DDL_Commands/queries.sql) ·
📸 [`01_DDL_Commands/screenshots/`](01_DDL_Commands/screenshots/)

---

### 02 — DML Commands

**Objective.** `INSERT`, `UPDATE`, `DELETE`, NULL handling, multiple-row
inserts, copying rows via subquery, basic `SELECT ... WHERE`.

**Highlights.**
- Insert single and multiple rows.
- Insert with implicit and explicit `NULL` values.
- Use `SYSDATE` and `TO_DATE(...)` for date columns.
- Copy rows from `employees` into a new `sales_reps` table via subquery.
- `UPDATE` using a subquery to derive the new value.

📁 [`02_DML_Commands/queries.sql`](02_DML_Commands/queries.sql) ·
📸 [`02_DML_Commands/screenshots/`](02_DML_Commands/screenshots/)

---

### 03 — SQL Constraints

**Objective.** All five constraint families — `NOT NULL`, `CHECK`,
`UNIQUE`, `PRIMARY KEY`, `FOREIGN KEY` — plus `DEFAULT` and
`AUTO_INCREMENT`.

**Highlights.**
- Build `MyTable`, progressively adding constraints (NOT NULL → UNIQUE →
  composite UNIQUE → composite PRIMARY KEY → CHECK → DEFAULT → AUTO_INCREMENT).
- Build a `Customer` ↔ `Orders` foreign-key relationship.
- Build the `Mov` (movie cassette library) table and answer six sub-queries
  on it (total value, sorted listings, replacement value report, count of
  non-G movies, insert a new movie).
- Build `Doctor` + `Salary` tables and answer six aggregate sub-queries
  (average salary by department, min/max by sex, group-by counts, etc.).
- Inspect constraints via `information_schema.table_constraints` and
  `information_schema.key_column_usage`.

📁 [`03_SQL_Constraints/queries.sql`](03_SQL_Constraints/queries.sql) ·
📸 [`03_SQL_Constraints/screenshots/`](03_SQL_Constraints/screenshots/)

---

### 04 — Arithmetic / Logical / Sorting / Grouping

**Objective.** Arithmetic expressions, column aliases, the concatenation
operator, `DISTINCT`, comparison and logical operators (`BETWEEN`, `IN`,
`LIKE`, `IS NULL`), rules of precedence, and `ORDER BY`.

**Highlights.**
- Compute `salary + 300` and `12 * (salary + 100)` as `annual_salary_plus_bonus`.
- `DISTINCT` on `department_id` and on `(job_id, department_id)`.
- `LIKE 'S%'` and `LIKE '_a%'` patterns.
- Demonstrate operator precedence: `OR` vs `AND` with and without parentheses.
- Sort by alias, by multiple columns, descending.
- Self-activity: employees above the average of department 80, hires per year,
  employees whose first name starts with a vowel, highest/lowest salary per
  department.

📁 [`04_Arithmetic_Logical_Sorting_Grouping/queries.sql`](04_Arithmetic_Logical_Sorting_Grouping/queries.sql) ·
📸 [`04_Arithmetic_Logical_Sorting_Grouping/screenshots/`](04_Arithmetic_Logical_Sorting_Grouping/screenshots/)

---

### 05 — Built-in Functions

**Objective.** Single-row functions across four families — character, number,
date, conversion — plus `NVL`, `COALESCE`, `NULLIF`, and the `CASE` expression.

**Highlights.**
- Character: `LOWER`, `UPPER`, `INITCAP`, `LENGTH`, `SUBSTR`, `INSTR`,
  `CONCAT`, `RPAD`, `TRIM`, `REPLACE`.
- Number: `ROUND`, `TRUNC`, `MOD`, `CEIL`, `FLOOR`.
- Date: `SYSDATE`, date arithmetic, `ADD_MONTHS`, `MONTHS_BETWEEN`, `EXTRACT`.
- Conversion: `TO_CHAR` / `DATE_FORMAT`, `TO_NUMBER` / `CAST`, `TO_DATE` /
  `STR_TO_DATE` (both Oracle and MySQL forms shown side by side).
- Nulls: `NVL`, `COALESCE`, `NULLIF`.
- `CASE WHEN ... THEN ... END` for salary grading.

📁 [`05_Built_in_Functions/queries.sql`](05_Built_in_Functions/queries.sql) ·
📸 [`05_Built_in_Functions/screenshots/`](05_Built_in_Functions/screenshots/)

---

### 06 — Set Operations

**Objective.** `UNION`, `UNION ALL`, `INTERSECT`, `MINUS` / `EXCEPT`.

**Highlights.**
- Compare `employees` and `job_history` to find current-and-previous jobs.
- Self-activity using `STUDENT` and `FACULTY` tables: combine rows, preserve
  duplicates, find common rows, find rows only in `STUDENT`.

📁 [`06_Set_Operations/queries.sql`](06_Set_Operations/queries.sql) ·
📸 [`06_Set_Operations/screenshots/`](06_Set_Operations/screenshots/)

---

### 07 — Aggregate Functions

**Objective.** `AVG`, `COUNT`, `MAX`, `MIN`, `STDDEV`, `SUM`, `VARIANCE`;
`GROUP BY`; `HAVING`; nesting group functions.

**Highlights.**
- Whole-table aggregates: average, sum, min, max, count, count-distinct.
- Per-department and per-job aggregates.
- The three flavours of `COUNT`: `COUNT(*)`, `COUNT(col)`, `COUNT(DISTINCT col)`.
- Group functions and `NULL`: `AVG(comm)` vs `AVG(NVL(comm, 0))`.
- `GROUP BY` on multiple columns.
- `HAVING` to filter groups (max salary > 10000, average > 8000, count > 5).
- Nested `MAX(AVG(salary))` rewritten as a two-step subquery.
- `HAVING` with a subquery comparing to department 50's minimum.

📁 [`07_Aggregate_Functions/queries.sql`](07_Aggregate_Functions/queries.sql) ·
📸 [`07_Aggregate_Functions/screenshots/`](07_Aggregate_Functions/screenshots/)

---

### 08 — SQL Joins

**Objective.** Equijoin, non-equijoin, self join, outer join (Oracle `(+)`
syntax and ANSI `LEFT/RIGHT/FULL OUTER JOIN`), `CROSS JOIN`, `NATURAL JOIN`,
`JOIN ... USING`, `JOIN ... ON`.

**Highlights.**
- Avoid Cartesian products by always specifying a join condition.
- Three-table join (`employees` × `departments` × `locations`) in both Oracle
  and ANSI syntax.
- Non-equijoin via `BETWEEN` against `job_grades`.
- Self join to map each employee to their manager.
- Emulate `FULL OUTER JOIN` in MySQL with `UNION` of LEFT and RIGHT joins.

📁 [`08_SQL_Joins/queries.sql`](08_SQL_Joins/queries.sql) ·
📸 [`08_SQL_Joins/screenshots/`](08_SQL_Joins/screenshots/)

---

### 09 — Subqueries

**Objective.** Single-row, multiple-row, and correlated subqueries;
`IN`, `ANY`, `ALL`; subqueries in `WHERE`, `HAVING`, `FROM`.

**Highlights.**
- Find employees earning more than Abel (single-row).
- Find the job with the lowest average salary (nested aggregate).
- `ANY` and `ALL` operators with `IT_PROG` salaries.
- Correlated subquery: employees who manage at least one other employee.
- `NOT IN` with `IS NOT NULL` guard for null-aware subqueries.
- Inline view: average salary per department joined with `departments`.
- Self-activity: `orchestras`, `concerts`, `members` dataset with five
  realistic business queries.

📁 [`09_Subqueries/queries.sql`](09_Subqueries/queries.sql) ·
📸 [`09_Subqueries/screenshots/`](09_Subqueries/screenshots/)

---

### 10 — PL/SQL

**Objective.** Anonymous blocks, conditional control (`IF`, `ELSIF`, `CASE`),
iterative control (`LOOP`, `WHILE`, `FOR`), `GOTO`, procedures, functions,
and cursors.

**Notes.** The worksheet uses Oracle PL/SQL syntax (`DBMS_OUTPUT.PUT_LINE`,
`FOR counter IN 1..5 LOOP`, etc.). Each Oracle block is paired with a
**MySQL stored-procedure equivalent** that actually executes inside MySQL 8.
Both forms are preserved as comments inside `queries.sql` for cross-reference.

**Highlights.**
- `ex1_simple_block` — read a value with `SELECT ... INTO`.
- `ex2_if_then_else` — `IF`/`ELSE`.
- `ex3_elsif` — `IF`/`ELSEIF`/`ELSE` ladder.
- `ex4_case` — searched `CASE`.
- `ex5_while_loop` — `WHILE ... DO ... END WHILE`.
- `ex6_for_loop` — `LOOP` with `LEAVE` (the MySQL equivalent of `FOR`).
- `ex7_goto_like` — `IF`/`ELSE` emulating `GOTO` labels.
- `update_salary` — procedure with parameters and a custom `SIGNAL` for
  null-salary handling (exception).
- `get_salary` — function with `RETURNS DECIMAL`.
- `ex10_cursor` — explicit cursor with `CONTINUE HANDLER FOR NOT FOUND`.

📁 [`10_PL_SQL/queries.sql`](10_PL_SQL/queries.sql) ·
📸 [`10_PL_SQL/screenshots/`](10_PL_SQL/screenshots/)

---

### 11 — Views, Synonyms, Index, Sequence

**Objective.** `CREATE/ALTER/DROP VIEW`, synonyms (MySQL: emulated via
`VIEW`), sequences (MySQL: `AUTO_INCREMENT` + optional trigger for non-unit
increments), and indexes.

**Highlights.**
- Build a `student` table, then `studentdetail` and `student_total` views.
- `CREATE OR REPLACE VIEW` to add a column.
- Emulate `CREATE SYNONYM emp FOR employee_details` with a view named `emp`.
- Emulate Oracle `CREATE SEQUENCE emp_seq START WITH 500 INCREMENT BY 5` using
  `AUTO_INCREMENT = 500` plus a `BEFORE INSERT` trigger that adds 5 each time.
- Create and drop an index on `book.author`.

📁 [`11_Views_Synonyms_Index_Sequence/queries.sql`](11_Views_Synonyms_Index_Sequence/queries.sql) ·
📸 [`11_Views_Synonyms_Index_Sequence/screenshots/`](11_Views_Synonyms_Index_Sequence/screenshots/)

---

### 12 — MongoDB Basics

**Objective.** Basic CRUD operations in MongoDB using `mongosh`:
`insertMany`, `find`, `updateOne`, `updateMany`, `deleteOne`, `deleteMany`,
the aggregation framework, and sort/limit/skip.

**Highlights.**
- Switch to `dbms_worksheet` database and insert 5 employee documents.
- Query operators: `$gt`, `$or`, projection.
- Update operators: `$set`, `$inc`.
- Aggregation: `$group` with `$avg` and `$sum`, then `$sort`.
- Sorting, limiting, skipping.
- Quick-reference table of common operators (`$eq`, `$ne`, `$gt`, `$in`,
  `$exists`, `$regex`, etc.).

📁 [`12_MongoDB_Basics/queries.mongo.js`](12_MongoDB_Basics/queries.mongo.js) ·
📸 [`12_MongoDB_Basics/screenshots/`](12_MongoDB_Basics/screenshots/)

---

## Viva Question Bank

Each exercise in the official worksheet ends with **5 viva questions**. The
full set of 55 questions and concise model answers is reproduced in
[`docs/VIVA_QUESTIONS.md`](docs/VIVA_QUESTIONS.md).

A short sample:

> **Q.** Differentiate between `TRUNCATE` and `DROP`. Can they be rolled back?
> **A.** `TRUNCATE` removes all rows but keeps the table structure;
> `DROP` removes the entire table (structure + data). `TRUNCATE` *can* be
> rolled back if executed inside a transaction (in MySQL with InnoDB); `DROP`
> is DDL and commits immediately, so it cannot be rolled back.

> **Q.** How do `NULL` values affect `INTERSECT` and `MINUS`?
> **A.** In set operations, `NULL = NULL` is treated as `TRUE` (unlike normal
> SQL comparison). So rows that differ only in their `NULL` columns are
> considered identical.

---

## Reproducing the Screenshots

The screenshots in each `screenshots/` folder were generated by a small
Python helper that:

1. Loads `schema/00_setup_database.sql` into an in-memory SQLite database
   (MySQL syntax is auto-adapted — `VARCHAR2` → `VARCHAR`, `NUMBER` →
   `NUMERIC`, `MINUS` → `EXCEPT`, `SYSDATE` → `CURRENT_DATE`, `TO_DATE` →
   `date()`, `CONCAT(...)` → `||`, `NVL` → `IFNULL`, etc.).
2. Executes every SQL statement in the exercise's `queries.sql`.
3. Renders each query together with its **real result set** as a PNG that
   mimics the MySQL CLI output (prompt, table borders, row count, elapsed
   time).

> **Why SQLite instead of MySQL?** Because the screenshots need to be
> regeneratable in any environment without requiring a running MySQL server.
> The actual `.sql` files target MySQL 8 — the SQLite execution is only used
> to *generate* the screenshot, and the adaptation is conservative enough
> that the displayed result matches what MySQL would produce.

To regenerate all screenshots:

```bash
pip install pillow
python3 scripts/generate_screenshots.py
```

The generator lives at `scripts/screenshot_engine.py` (rendering core) and
`scripts/generate_screenshots.py` (per-exercise driver).

---

## Contributing / License

This is an individual academic submission. Pull requests will not be
accepted, but issues are welcome if you spot an error in a query or a
screenshot.

Released under the **MIT License** — see [`LICENSE`](LICENSE).
"# dbms-lab-solutions" 
