# Viva Question Bank

This document consolidates the 5 viva questions at the end of each of the 12
exercises in the DBMS worksheet, along with concise model answers.

---

## Exercise 01 — DDL Commands

**1. Differentiate between `TRUNCATE` and `DROP`. Can they be rolled back? Why or why not?**

`TRUNCATE` removes all rows from a table but keeps its structure; `DROP`
deletes the entire table including its structure. `TRUNCATE` *can* sometimes
be rolled back if used inside a transaction (DBMS-dependent — supported in
MySQL InnoDB), but `DROP` cannot be rolled back because it commits
immediately. `TRUNCATE` is faster and uses less logging than `DELETE`.

**2. What happens if you try to drop a column that is part of a composite primary key?**

The DBMS raises an error and refuses the operation, because dropping such a
column would break the integrity of the primary key constraint. You must
first drop the primary key constraint before dropping the column.

**3. What is the purpose of the `NVL` function in SQL?**

`NVL(expression, replacement_value)` replaces `NULL` with the specified
replacement value. It is used to avoid `NULL`-related issues in expressions
and aggregates. Example: `NVL(salary, 0)` returns `0` if `salary` is `NULL`.
(MySQL equivalent: `IFNULL` or `COALESCE`.)

**4. How does altering a table (adding/dropping columns) affect existing indexes and constraints?**

Adding a column does **not** affect existing indexes or constraints.
Dropping a column **does** affect them if the column participates in an
index, primary key, or foreign key — the DBMS will either raise an error
or require you to drop the constraint/index first.

**5. When you rename a table or column, how can you ensure dependent objects like views and procedures are updated?**

Renaming does **not** automatically update dependent objects. You must
manually find (via `information_schema.views`, `information_schema.routines`,
etc.) and rewrite each dependent view or procedure to use the new name.

---

## Exercise 02 — DML Commands

**1. Differentiate between `DELETE` and `TRUNCATE`.**

| Aspect | `DELETE` | `TRUNCATE` |
|--------|----------|------------|
| Type   | DML      | DDL        |
| `WHERE` clause | Supported | Not supported |
| Rollback | Yes (inside txn) | DBMS-dependent |
| Triggers | Fires | Does not fire |
| Speed  | Slower (row-by-row log) | Faster (deallocates pages) |

**2. What is the role of `COMMIT`, `ROLLBACK`, and `SAVEPOINT`?**

`COMMIT` makes all changes since the last commit permanent.
`ROLLBACK` undoes all changes since the last commit (or savepoint).
`SAVEPOINT` marks a point inside a transaction to which you can roll back
partially without rolling back the whole transaction.

**3. How does `INSERT ... SELECT` differ from a regular `INSERT`?**

A regular `INSERT` adds explicitly listed values (`VALUES (...)`).
`INSERT ... SELECT` inserts the *result set* of a `SELECT` query into the
target table, allowing you to copy or transform data from one (or more)
source tables in a single statement.

**4. Importance of transactions when dealing with multiple `UPDATE` statements?**

Without a transaction, each `UPDATE` commits independently — if a later
statement fails, earlier changes are still persisted, leaving the database
in an inconsistent state. Wrapping them in `BEGIN ... COMMIT` makes the
group atomic: either all succeed, or all are rolled back.

**5. How to delete records older than 10 years from a large audit log table while avoiding locking issues?**

- Delete in small batches using `DELETE ... WHERE ... LIMIT 1000` in a loop.
- Partition the table by date so old data can be dropped via `ALTER TABLE
  ... DROP PARTITION`.
- Schedule the purge during off-peak hours.
- Temporarily disable non-critical indexes, rebuild them after the purge.

---

## Exercise 03 — SQL Constraints

**1. Which constraint ensures that a column cannot have `NULL` values?**

The `NOT NULL` constraint.

**2. Why define constraints at table-creation time rather than adding them later?**

Defining constraints up-front guarantees data integrity from the very first
`INSERT`. Adding them later risks rejecting existing rows or requiring a
data-cleanup pass first.

**3. Downsides of too many constraints or indexes on a frequently-updated table?**

Each constraint/index adds overhead on every `INSERT`, `UPDATE`, `DELETE`
(the DBMS must re-validate constraints and update index structures). This
slows write throughput and consumes extra storage.

**4. How do you make a column auto-increment in SQL?**

- MySQL: `id INT AUTO_INCREMENT PRIMARY KEY`.
- PostgreSQL: `id SERIAL PRIMARY KEY` (or `GENERATED ALWAYS AS IDENTITY`).
- Oracle 12c+: `id GENERATED ALWAYS AS IDENTITY`.

**5. How do you assign a default value to a column?**

Use the `DEFAULT` keyword during column definition:
`status VARCHAR(10) DEFAULT 'active'`.

---

## Exercise 04 — Arithmetic / Logical / Sorting / Grouping

**1. How does `WHERE` differ from `HAVING`?**

`WHERE` filters individual rows **before** grouping; `HAVING` filters groups
**after** `GROUP BY` is applied. Aggregates cannot appear in `WHERE` but
can in `HAVING`.

**2. Difference between `BETWEEN` and `IN`?**

`BETWEEN a AND b` matches values in the inclusive range `[a, b]`.
`IN (v1, v2, v3)` matches values in the explicit list. `BETWEEN` is
range-based; `IN` is enumeration-based.

**3. How does the `LIKE` operator work?**

`LIKE` matches string patterns. `%` matches any sequence of zero or more
characters; `_` matches exactly one character. Example: `LIKE 'S%'` matches
any string starting with `S`.

**4. Difference between `ORDER BY` and `GROUP BY`?**

`ORDER BY` sorts the final result set; `GROUP BY` collapses rows that share
the grouped column values into one row per group, typically used with
aggregates.

**5. Why use column aliases? Rules?**

Aliases rename a column or expression in the output (`SELECT salary * 12 AS
annual_salary`). They make output more readable and can be referenced in
`ORDER BY` (but not in `WHERE` or `GROUP BY` in standard SQL).

---

## Exercise 05 — Built-in Functions

**1. Difference between single-row and aggregate functions?**

Single-row functions operate on **one row at a time** and return one result
per row (`UPPER`, `ROUND`, `SUBSTR`). Aggregate functions operate on **sets
of rows** and return one result per group (`SUM`, `AVG`, `COUNT`).

**2. How does `COALESCE` differ from `NVL`?**

`NVL(expr, repl)` accepts exactly two arguments. `COALESCE(expr1, expr2,
..., exprN)` accepts two or more and returns the first non-NULL value.
`COALESCE` is the SQL-standard form; `NVL` is Oracle-specific.

**3. Why is `TO_CHAR` used, and how does it differ from `CAST`?**

`TO_CHAR(value, format)` converts a date or number to a string using a
**format mask** (e.g. `'DD-Mon-YYYY'`). `CAST(value AS type)` performs a
generic type conversion **without** a format mask.

**4. Explain the `CASE` expression.**

`CASE WHEN cond1 THEN v1 WHEN cond2 THEN v2 ELSE v3 END` returns a value
based on conditions, evaluated in order. Use it to compute derived columns
without a subquery (e.g. salary bands, status labels).

**5. Difference between `ROUND` and `TRUNC`?**

`ROUND(45.926, 2)` → `45.93` (rounds to nearest).
`TRUNC(45.926, 2)` → `45.92` (truncates, no rounding).

---

## Exercise 06 — Set Operations

**1. Limitations / factors affecting set operations?**

Both queries must return the same number of columns with compatible data
types. `UNION` and `INTERSECT` perform sort/dedup operations that can be
expensive on large datasets. Some DBMSs disallow `CLOB`/`BLOB` columns in
set operations.

**2. How is `UNION` different from `JOIN`?**

`UNION` combines **rows** from two queries vertically (duplicates removed
by default). `JOIN` combines **columns** from two or more tables
horizontally based on a related key.

**3. Performance impact of set operations vs `JOIN`s and subqueries?**

`UNION`/`INTERSECT`/`MINUS` typically involve sorting and deduplication,
which can be slower than well-indexed `JOIN`s. Subqueries that can be
rewritten as `JOIN`s often perform better.

**4. What happens if column counts don't match in a `UNION`?**

The DBMS raises a compile-time error; the query does not execute.

**5. How do `NULL`s affect `INTERSECT` and `MINUS`?**

In set operations, `NULL = NULL` is treated as `TRUE` — rows differing
only in their `NULL` columns are considered equal. This differs from normal
SQL comparison.

---

## Exercise 07 — Aggregate Functions

**1. Difference between `WHERE` and `HAVING`?**

`WHERE` filters rows **before** aggregation; `HAVING` filters groups
**after** aggregation. Example: `HAVING AVG(salary) > 5000` is valid; the
equivalent in `WHERE` is not.

**2. Can aggregate functions be used on text columns like `VARCHAR`?**

`SUM` and `AVG` require numeric input. `COUNT`, `MIN`, `MAX` work on any
comparable type, including text.

**3. Result of using an aggregate without `GROUP BY`?**

The whole table is treated as one group; a single summary row is returned.
Appropriate when you want an overall summary (total salary, max hire date).

**4. Difference between `COUNT(*)`, `COUNT(col)`, `COUNT(DISTINCT col)`?**

- `COUNT(*)` — counts all rows, including `NULL`s.
- `COUNT(col)` — counts non-`NULL` values of `col`.
- `COUNT(DISTINCT col)` — counts unique non-`NULL` values of `col`.

**5. How does `SUM()` treat `NULL` values?**

`SUM()` ignores `NULL`s — only non-`NULL` numbers are added. If every row
is `NULL`, the result is `NULL` (not `0`).

---

## Exercise 08 — SQL Joins

**1. Difference between `INNER JOIN` and `OUTER JOIN`?**

`INNER JOIN` returns only rows that match in **both** tables. `OUTER JOIN`
preserves unmatched rows from one or both tables (`LEFT`, `RIGHT`, or
`FULL`), filling missing columns with `NULL`.

**2. Problem of forgetting a join condition?**

You get a **Cartesian product** — every row of one table joined to every
row of the other, producing huge meaningless result sets.

**3. How does a `JOIN` between books and authors avoid data duplication?**

By linking via a foreign key, you store author details once in the `authors`
table and only reference them by `author_id` in `books`. No need to repeat
author info on every book row.

**4. `JOIN ... ON` vs `JOIN ... USING(...)`?**

`ON` allows arbitrary join conditions (any columns, any comparison).
`USING(col)` is shorter but requires the same column name in both tables
and only supports equality.

**5. How do `NULL`s in join columns affect `INNER JOIN` vs `OUTER JOIN`?**

`INNER JOIN` drops rows where the join key is `NULL` (because `NULL = NULL`
is `UNKNOWN`). `OUTER JOIN` preserves them, showing `NULL`s on the
missing side.

---

## Exercise 09 — Subqueries

**1. Difference between correlated and non-correlated subqueries?**

A **non-correlated** subquery can run independently of the outer query —
it executes once and its result is reused. A **correlated** subquery
references the outer query's row and is re-evaluated for each outer row.

**2. What problem might occur if you forget a join condition in a multi-table query?**

A Cartesian product: every row of one table paired with every row of the
other, producing huge meaningless result sets.

**3. How does a `JOIN` between books and authors help avoid data duplication?**

It links via a foreign key, avoiding repeated author details for every
book row.

**4. `JOIN ... ON` vs `JOIN ... USING(...)`. When is each preferred?**

`ON` allows flexible join conditions; `USING(col)` is shorter but works
only when both tables have the same column name.

**5. How do `NULL` values in join columns affect `INNER JOIN` vs `OUTER JOIN`?**

`INNER JOIN` drops rows with `NULL` join keys; `OUTER JOIN` preserves them,
showing `NULL`s on the missing side.

---

## Exercise 10 — PL/SQL

**1. How do exceptions in PL/SQL contribute to robust programming?**

Exceptions let you handle runtime errors gracefully without crashing the
program. The `EXCEPTION` block catches specific error conditions and lets
the program continue or terminate cleanly with a meaningful message.

**2. How does PL/SQL handle context switch between SQL and procedural logic?**

Every SQL statement inside a PL/SQL block causes a context switch between
the PL/SQL engine and the SQL engine. Excessive switches (e.g. row-by-row
loops) hurt performance. Use `BULK COLLECT` / `FORALL` to batch them.

**3. How is recursion handled in PL/SQL? Should it be used?**

Recursion is implemented by a procedure/function calling itself. Use it
sparingly: deep recursion can exhaust the stack. Prefer iterative
solutions for unbounded inputs.

**4. How do you log errors without cluttering business logic?**

Write to a separate logging table or package (`DBMS_UTILITY` /
autonomous transactions) from inside the `EXCEPTION` block. This keeps the
main business logic clean while preserving a full audit trail.

**5. What is an anonymous block in PL/SQL?**

A PL/SQL block without a name, declared inline with `DECLARE ... BEGIN ...
END;`. Used for one-off tasks — it cannot be stored in the database or
called by name.

---

## Exercise 11 — Views, Synonyms, Index, Sequence

**1. How can views implement row-level security in a multi-user database?**

Create a view that filters rows based on the current user (e.g. `WHERE
owner = CURRENT_USER`) and grant users access only to the view — not the
underlying table. Different users see different subsets of rows.

**2. Risks of using updatable views?**

Complex views (joins, aggregates) may not be safely updatable; `INSERT`/
`UPDATE` through them can silently fail or produce inconsistent data.
Without `WITH CHECK OPTION`, you can insert rows that won't appear in the
view afterwards.

**3. When might synonyms cause confusion in a large-scale application?**

Synonyms hide the real schema/object behind an alias. In a large codebase
with many synonyms, developers may struggle to find the underlying object,
leading to maintenance issues, accidental shadowing, or broken dependencies
when the synonym's target is renamed.

**4. When can an index make query performance worse?**

On small tables (sequential scan is cheaper), on columns with low
selectivity (e.g. boolean flags), or on tables with heavy write load (each
write must update every index). Over-indexing also wastes storage.

**5. Why choose a sequence over an `AUTO_INCREMENT` column, or vice versa?**

`AUTO_INCREMENT` is per-table and simple. A **sequence** is independent of
any table — it can be shared across tables, used in application code,
cached, or cycled. Use sequences when you need cross-table uniqueness or
application-level control.

---

## Exercise 12 — MongoDB

**1. Difference between SQL databases and MongoDB?**

SQL databases store data in **tables with a fixed schema**; MongoDB stores
data as **JSON-like documents** with a flexible schema. SQL uses SQL query
language; MongoDB uses a JavaScript-style query API.

**2. What is a collection in MongoDB?**

A collection is analogous to a SQL table — it groups related documents.
Unlike a table, documents in a collection can have different fields.

**3. How does MongoDB ensure data consistency without transactions?**

Single-document operations are atomic. For multi-document transactions,
MongoDB 4.0+ supports distributed transactions across replica sets and
sharded clusters.

**4. What is the purpose of an index in MongoDB?**

Indexes speed up query performance by allowing MongoDB to find documents
without scanning the entire collection. They support equality, range,
and sort operations, at the cost of slower writes and extra storage.

**5. How does MongoDB handle scaling compared to SQL databases?**

MongoDB supports **horizontal scaling** via **sharding** — data is
distributed across multiple nodes. SQL databases traditionally scale
**vertically** (bigger server), though some modern SQL DBs also support
sharding.
