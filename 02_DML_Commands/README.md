# Exercise 02 — DML Commands

**Activity Sheet 2**

## Objective

- Describe each DML statement (`INSERT`, `UPDATE`, `DELETE`)
- Insert rows into tables (single, multiple, with NULLs, with subquery)
- Update rows in a table (specific rows, all rows, with a subquery)
- Delete rows from a table

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All DML queries from the worksheet (commented, runnable). |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. `INSERT` basic syntax (single row).
2. Inserting with NULL values (implicit and explicit).
3. Inserting special values (`SYSDATE`) and specific dates (`TO_DATE`).
4. Inserting multiple rows in one statement.
5. Copying rows from another table using a subquery.
6. `UPDATE` (specific rows, all rows, with subquery) and `DELETE`.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-02--dml-commands`](../docs/VIVA_QUESTIONS.md).
