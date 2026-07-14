# Exercise 12 — Advanced Databases: MongoDB (Basic Operations)

**Activity Sheet 12**

## Objective

- Install MongoDB on Linux/Windows
- Perform CRUD operations in MongoDB using the `mongosh` shell
- Use query operators (`$gt`, `$or`, `$in`, etc.)
- Use the aggregation framework (`$group`, `$avg`, `$sum`, `$sort`)
- Sort, limit, and skip results

## What this folder contains

| File | Purpose |
|------|---------|
| `queries.mongo.js` | All MongoDB shell commands, runnable end-to-end. |
| `screenshots/` | One PNG per logical section (editor style, JS highlighting). |

## Sections covered

1. Switch to the `dbms_worksheet` database.
2. `insertMany` documents into `employees`.
3. `find` with single condition, AND, OR, and projection.
4. `updateOne`, `updateMany` (`$set`, `$inc`).
5. `deleteOne`, `deleteMany`.
6. Aggregation framework — average salary per department, count per department.
7. `sort`, `limit`, `skip`.
8. Drop collection and database.

## How to run

```bash
# Start mongod if not already running
mongod --dbpath /path/to/data &

# Run the script
mongosh < queries.mongo.js
```

## Viva Questions (recap)

See [`../docs/VIVA_QUESTIONS.md#exercise-12--mongodb`](../docs/VIVA_QUESTIONS.md).
