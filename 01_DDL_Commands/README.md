# Exercise 01 — DDL Commands

**Activity Sheet 1**

## Objective

After completing this exercise, the student will be able to:
- Categorize the main database objects
- Review a table structure
- Create, alter, drop, and truncate tables

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All DDL queries from the worksheet (commented, runnable). |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. **Self-Activity 1** — create `Country`, rename to `my_country`, add/modify/drop columns.
2. **TRUNCATE vs DROP demonstration** — clone a table, truncate it, then drop it.
3. **CREATE TABLE ... AS subquery** — clone the structure and data of `employees`.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-01--ddl-commands`](../docs/VIVA_QUESTIONS.md).
