# Exercise 10 — PL/SQL

**Activity Sheet 10**

## Objective

- Write anonymous PL/SQL blocks
- Use conditional control (`IF`, `ELSIF`, `CASE`)
- Use iterative control (`LOOP`, `WHILE`, `FOR`)
- Create procedures and functions with parameters
- Handle exceptions

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All PL/SQL examples (Oracle syntax in comments + MySQL stored-procedure equivalents). |
| `screenshots/` | One PNG per logical section, rendered in an editor style. |

## Sections covered

1. `ex1_simple_block` — `SELECT ... INTO`.
2. `ex2_if_then_else` — `IF`/`ELSE`.
3. `ex3_elsif` — `IF`/`ELSEIF`/`ELSE` ladder.
4. `ex4_case` — searched `CASE`.
5. `ex5_while_loop` — `WHILE ... DO ... END WHILE`.
6. `ex6_for_loop` — `LOOP` with `LEAVE` (MySQL emulation of `FOR`).
7. `ex7_goto_like` — `IF`/`ELSE` emulating `GOTO`.
8. `update_salary` — procedure with parameters and exception (`SIGNAL`).
9. `get_salary` — function returning `DECIMAL`.
10. `ex10_cursor` — explicit cursor with `CONTINUE HANDLER FOR NOT FOUND`.
11. Cleanup of all procedures and functions.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

> **Note.** The worksheet teaches Oracle PL/SQL syntax (`DBMS_OUTPUT.PUT_LINE`,
> `FOR counter IN 1..5 LOOP`, etc.). MySQL 8 does not support anonymous
> PL/SQL blocks, so each example is wrapped in a stored procedure. The
> original Oracle syntax is preserved as comments for cross-reference.

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-10--plsql`](../docs/VIVA_QUESTIONS.md).
