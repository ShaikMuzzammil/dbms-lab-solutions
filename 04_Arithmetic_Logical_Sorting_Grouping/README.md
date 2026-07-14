# Exercise 04 — Arithmetic / Logical Operations, Sorting and Grouping

**Activity Sheet 4**

## Objective

- List the capabilities of the SQL SELECT statement
- Execute a basic SELECT statement using arithmetic operators
- Use comparison and logical operators
- Sort rows with `ORDER BY`

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All SELECT queries from the worksheet. |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. Arithmetic expressions and column aliases.
2. Concatenation and literal character strings.
3. `DISTINCT` and comparison conditions (`BETWEEN`, `IN`, `LIKE`, `IS NULL`).
4. Rules of precedence (`AND` vs `OR`).
5. `ORDER BY` (single column, alias, multiple columns).
6. Self-activity queries.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-04--arithmetic--logical--sorting--grouping`](../docs/VIVA_QUESTIONS.md).
