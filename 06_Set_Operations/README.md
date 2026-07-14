# Exercise 06 — Using Set Operators

**Activity Sheet 6**

## Objective

- Describe set operators
- Use a set operator to combine multiple queries into a single query
- Control the order of rows returned

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All set-operation queries from the worksheet. |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. `UNION` (current and previous jobs of employees).
2. `UNION ALL` (preserves duplicates, no implicit sort).
3. `INTERSECT` (employees whose current job matches their original job).
4. `MINUS` / `EXCEPT` (employees who have never changed jobs).
5. Self-activity using `STUDENT` and `FACULTY` tables.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-06--set-operations`](../docs/VIVA_QUESTIONS.md).
