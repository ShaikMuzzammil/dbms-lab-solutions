# Exercise 03 — SQL Constraints

**Activity Sheet 3**

## Objective

- Describe the constraints
- Create and maintain the constraints

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All constraint DDL + DML queries from the worksheet. |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. `MyTable` — NOT NULL → UNIQUE → composite UNIQUE → composite PRIMARY KEY → CHECK → DEFAULT → AUTO_INCREMENT.
2. `Customer` ↔ `Orders` foreign-key relationship.
3. `Mov` (movie cassette library) — six aggregate sub-queries.
4. `Doctor` + `Salary` — six aggregate join sub-queries.
5. Viewing constraints via `information_schema`.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-03--sql-constraints`](../docs/VIVA_QUESTIONS.md).
