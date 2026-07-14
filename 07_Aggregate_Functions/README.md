# Exercise 07 — Aggregate Functions

**Activity Sheet 7**

## Objective

- Identify the available group functions
- Describe the use of group functions
- Group data by using the `GROUP BY` clause
- Include or exclude grouped rows by using the `HAVING` clause

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All aggregate-function queries from the worksheet. |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. Basic aggregates over the whole table (`AVG`, `SUM`, `MIN`, `MAX`, `COUNT`).
2. `AVG`/`SUM` and `MIN`/`MAX` per department/job.
3. `COUNT(*)`, `COUNT(col)`, `COUNT(DISTINCT col)`.
4. Group functions and `NULL` values.
5. `GROUP BY` with multiple columns.
6. `HAVING` clause and nested group functions.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-07--aggregate-functions`](../docs/VIVA_QUESTIONS.md).
