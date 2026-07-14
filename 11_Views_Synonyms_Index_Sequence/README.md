# Exercise 11 — Views, Synonyms, Index, Sequence

**Activity Sheet 11**

## Objective

- Describe a view
- Create, alter the definition of, and drop a view
- Retrieve data through a view
- Insert, update, and delete data through a view
- Create and use an inline view
- Create and use synonyms, sequences, and indexes

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.sql` | All views/synonyms/sequence/index DDL + DML. |
| `screenshots/` | One PNG per logical section + an `_overview.png`. |

## Sections covered

1. `CREATE VIEW studentdetail` + `CREATE OR REPLACE VIEW` to add a column + `DROP VIEW`.
2. Synonym emulation via `CREATE VIEW emp AS SELECT * FROM employee_details`.
3. Sequence emulation via `AUTO_INCREMENT = 500` + `BEFORE INSERT` trigger (increment by 5).
4. `CREATE INDEX author_idx ON book(author)` + `SHOW INDEX` + `DROP INDEX`.

## How to run

```bash
mysql -u root -p < ../schema/00_setup_database.sql
mysql -u root -p dbms_worksheet < queries.sql
```

> **Note.** MySQL does not support `CREATE SYNONYM` or `CREATE SEQUENCE`.
> The Oracle worksheet syntax is preserved as comments; runnable MySQL
> equivalents (using views and triggers) are provided.

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-11--views-synonyms-index-sequence`](../docs/VIVA_QUESTIONS.md).
