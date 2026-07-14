# Exercise 08 — SQL Joins

**Activity Sheet 8**

## Objective

- Write SELECT statements to access data from more than one table using
  equality and non-equality joins
- View data that generally does not meet a join condition by using outer joins
- Join a table to itself by using a self join

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All join queries from the worksheet. |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. Cartesian products (and how to avoid them).
2. Equijoin (Oracle and ANSI syntaxes).
3. Joining more than two tables (Employees × Departments × Locations).
4. Non-equijoin via `BETWEEN` against `job_grades`.
5. Outer joins (Oracle `(+)` syntax).
6. Self join.
7. `CROSS JOIN`, `NATURAL JOIN`, `JOIN ... USING`, `JOIN ... ON`.
8. `LEFT OUTER JOIN`, `RIGHT OUTER JOIN`, `FULL OUTER JOIN` (emulated in MySQL).
9. Three-way ANSI join.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-08--sql-joins`](../docs/VIVA_QUESTIONS.md).
