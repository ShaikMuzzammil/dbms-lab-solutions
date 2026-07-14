-- =============================================================================
-- Exercise 12 - Advanced Databases: MongoDB (Basic Operations)
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: Insert, find, update, delete, query operators in MongoDB.
-- =============================================================================

-- This file mirrors the SQL worksheet exercises but in MongoDB shell syntax.
-- It is intended to be run inside the `mongosh` (MongoDB Shell) client.
--
-- Launch mongosh and switch to the worksheet database:
--   $ mongosh
--   > use dbms_worksheet

// ---------------------------------------------------------------------------
// 1. Create / switch to a database
// ---------------------------------------------------------------------------
use dbms_worksheet;

// ---------------------------------------------------------------------------
// 2. Create a collection and insert documents
// ---------------------------------------------------------------------------
db.employees.insertMany([
  { emp_id: 100, first_name: "Steven", last_name: "King",
    email: "SKING", salary: 24000, department: "Executive" },
  { emp_id: 101, first_name: "Neena", last_name: "Kochhar",
    email: "NKOCHHAR", salary: 17000, department: "Executive" },
  { emp_id: 103, first_name: "Alexander", last_name: "Hunold",
    email: "AHUNOLD", salary: 9000, department: "IT" },
  { emp_id: 104, first_name: "Bruce", last_name: "Ernst",
    email: "BERNST", salary: 6000, department: "IT" },
  { emp_id: 145, first_name: "John", last_name: "Russell",
    email: "JRUSSEL", salary: 14000, department: "Sales" }
]);

// ---------------------------------------------------------------------------
// 3. Find all documents
// ---------------------------------------------------------------------------
db.employees.find().pretty();

// Find by a single condition
db.employees.find({ department: "IT" }).pretty();

// Find by multiple conditions (AND)
db.employees.find({ department: "IT", salary: { $gt: 7000 } }).pretty();

// Find with OR
db.employees.find({
    $or: [
        { department: "Executive" },
        { salary: { $gt: 12000 } }
    ]
}).pretty();

// Projection - select specific fields
db.employees.find({}, { first_name: 1, last_name: 1, salary: 1, _id: 0 }).pretty();

// ---------------------------------------------------------------------------
// 4. Update documents
// ---------------------------------------------------------------------------
// Update a single document
db.employees.updateOne(
    { emp_id: 104 },
    { $set: { salary: 6500 } }
);

// Update many documents
db.employees.updateMany(
    { department: "IT" },
    { $set: { region: "Bangalore" } }
);

// Increment a numeric field
db.employees.updateOne(
    { emp_id: 101 },
    { $inc: { salary: 1000 } }
);

db.employees.find({ department: "IT" }).pretty();

// ---------------------------------------------------------------------------
// 5. Delete documents
// ---------------------------------------------------------------------------
db.employees.deleteOne({ emp_id: 145 });

db.employees.deleteMany({ department: "Sales" });

db.employees.find().pretty();

// ---------------------------------------------------------------------------
// 6. Aggregation framework - GROUP BY equivalent
// ---------------------------------------------------------------------------
// Average salary per department
db.employees.aggregate([
    { $group: { _id: "$department", avgSalary: { $avg: "$salary" } } },
    { $sort:  { avgSalary: -1 } }
]);

// Count of employees per department
db.employees.aggregate([
    { $group: { _id: "$department", count: { $sum: 1 } } },
    { $sort:  { count: -1 } }
]);

// ---------------------------------------------------------------------------
// 7. Sorting, limiting, skipping
// ---------------------------------------------------------------------------
db.employees.find().sort({ salary: -1 }).limit(3).pretty();
db.employees.find().sort({ first_name: 1 }).skip(1).limit(2).pretty();

// ---------------------------------------------------------------------------
// 8. Drop collection and database
// ---------------------------------------------------------------------------
db.employees.drop();
db.dropDatabase();

// ---------------------------------------------------------------------------
// Common operators - quick reference
// ---------------------------------------------------------------------------
//  $eq   = equal to                  { field: { $eq: value } }
//  $ne   = not equal                 { field: { $ne: value } }
//  $gt   = greater than              { field: { $gt: value } }
//  $gte  = greater than or equal     { field: { $gte: value } }
//  $lt   = less than                 { field: { $lt: value } }
//  $lte  = less than or equal        { field: { $lte: value } }
//  $in   = matches any value in arr  { field: { $in: [a,b,c] } }
//  $nin  = not in array              { field: { $nin: [a,b] } }
//  $and  = logical AND               { $and: [ {c1}, {c2} ] }
//  $or   = logical OR                { $or:  [ {c1}, {c2} ] }
//  $not  = logical NOT               { field: { $not: { $gt: 5 } } }
//  $exists = field exists            { field: { $exists: true } }
//  $regex  = regex match             { field: { $regex: "^S" } }
