# Exercise 05 — Built-in Functions

**Activity Sheet 5**

## Objective

- Describe the various types of single-row functions available in SQL
- Use character, number, and date functions in SELECT statements
- Use conversion functions and CASE expressions

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All built-in function queries (Oracle + MySQL syntax side-by-side). |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. Character functions (`LOWER`, `UPPER`, `LENGTH`, `SUBSTR`, `INSTR`, `CONCAT`, `RPAD`, `TRIM`, `REPLACE`).
2. Number functions (`ROUND`, `TRUNC`, `MOD`, `CEIL`, `FLOOR`).
3. Date functions (`SYSDATE`, date arithmetic, `ADD_MONTHS`, `MONTHS_BETWEEN`, `EXTRACT`).
4. Conversion functions (`TO_CHAR` / `DATE_FORMAT`, `TO_NUMBER` / `CAST`, `TO_DATE` / `STR_TO_DATE`).
5. Implicit conversion.
6. `NVL`, `COALESCE`, `NULLIF`.
7. `CASE WHEN ... THEN ... END`.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-05--built-in-functions`](../docs/VIVA_QUESTIONS.md).
