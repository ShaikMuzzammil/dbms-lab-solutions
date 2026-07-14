# Exercise 09 — SQL Subqueries

**Activity Sheet 9**

## Objective

- Define subqueries
- Describe the types of problems that subqueries can solve
- List the types of subqueries
- Write single-row and multiple-row subqueries

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All subquery examples and the orchestras self-activity. |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. Single-row subquery (employees earning more than Abel).
2. Multiple conditions with two single-row subqueries.
3. Group function inside a subquery.
4. `HAVING` with subquery (departments with min salary > dept 50's min).
5. Multiple-row subqueries with `IN`, `ANY`, `ALL`.
6. Correlated subquery (employees who manage others).
7. Subquery in `FROM` clause + orchestras self-activity.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-09--subqueries`](../docs/VIVA_QUESTIONS.md).
