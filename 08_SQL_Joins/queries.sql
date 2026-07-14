-- =============================================================================
-- Exercise 08 - SQL Joins
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: Equijoin, non-equijoin, self join, outer join (LEFT / RIGHT /
--            FULL), CROSS JOIN, NATURAL JOIN, USING, ON.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Cartesian product (avoid! shown only to illustrate what NOT to do)
-- ---------------------------------------------------------------------------
SELECT last_name, department_name
FROM   employees, departments
LIMIT  10;

-- ---------------------------------------------------------------------------
-- Equijoin (Oracle syntax)
-- ---------------------------------------------------------------------------
SELECT e.employee_id, e.last_name, e.department_id,
       d.department_id, d.location_id
FROM   employees e, departments d
WHERE  e.department_id = d.department_id
LIMIT  10;

-- Additional search conditions (AND)
SELECT last_name, e.department_id, department_name
FROM   employees e, departments d
WHERE  e.department_id = d.department_id
  AND  e.last_name = 'Matos';

-- Using table aliases (same query)
SELECT e.employee_id, e.last_name, e.department_id,
       d.department_id, d.location_id
FROM   employees e, departments d
WHERE  e.department_id = d.department_id
LIMIT  10;

-- ---------------------------------------------------------------------------
-- Joining more than two tables (Employees + Departments + Locations)
-- ---------------------------------------------------------------------------
SELECT e.last_name, d.department_name, l.city
FROM   employees e, departments d, locations l
WHERE  e.department_id = d.department_id
  AND  d.location_id  = l.location_id
LIMIT  10;

-- ---------------------------------------------------------------------------
-- Non-equijoin (Employees + Job_Grades via BETWEEN)
-- ---------------------------------------------------------------------------
SELECT e.last_name, e.salary, j.grade_level
FROM   employees e, job_grades j
WHERE  e.salary BETWEEN j.lowest_salary AND j.highest_salary
LIMIT  15;

-- ---------------------------------------------------------------------------
-- Outer joins (Oracle (+) syntax)
-- ---------------------------------------------------------------------------
-- Show all departments even if they have no employees
SELECT e.last_name, e.department_id, d.department_name
FROM   employees e, departments d
WHERE  e.department_id(+) = d.department_id
LIMIT  10;

-- ---------------------------------------------------------------------------
-- Self join - find each employee and their manager
-- ---------------------------------------------------------------------------
SELECT worker.last_name  AS employee,
       manager.last_name AS manager
FROM   employees worker, employees manager
WHERE  worker.manager_id = manager.employee_id
LIMIT  10;

-- ---------------------------------------------------------------------------
-- ANSI JOIN syntaxes
-- ---------------------------------------------------------------------------
-- CROSS JOIN
SELECT last_name, department_name
FROM   employees
CROSS  JOIN departments
LIMIT  10;

-- NATURAL JOIN
SELECT department_id, department_name, location_id, city
FROM   departments
NATURAL JOIN locations
LIMIT  10;

-- JOIN ... USING
SELECT l.city, d.department_name
FROM   locations l
JOIN   departments d USING (location_id)
WHERE  d.location_id = 1400;

SELECT e.employee_id, e.last_name, d.location_id
FROM   employees e
JOIN   departments d USING (department_id)
LIMIT  10;

-- JOIN ... ON
SELECT e.employee_id, e.last_name, e.department_id,
       d.department_id, d.location_id
FROM   employees e
JOIN   departments d ON (e.department_id = d.department_id)
LIMIT  10;

-- Self join with ANSI ON
SELECT e.last_name AS emp, m.last_name AS mgr
FROM   employees e
JOIN   employees m ON (e.manager_id = m.employee_id)
LIMIT  10;

-- ---------------------------------------------------------------------------
-- LEFT OUTER JOIN  - all employees, even those without a department
-- ---------------------------------------------------------------------------
SELECT e.last_name, e.department_id, d.department_name
FROM   employees e
LEFT OUTER JOIN departments d ON (e.department_id = d.department_id)
WHERE  e.department_id IS NULL;

-- RIGHT OUTER JOIN  - all departments, even those without employees
SELECT e.last_name, d.department_id, d.department_name
FROM   employees e
RIGHT OUTER JOIN departments d ON (e.department_id = d.department_id)
WHERE  e.employee_id IS NULL
LIMIT  10;

-- FULL OUTER JOIN  - both sides preserved
-- MySQL does not natively support FULL OUTER JOIN; emulate with UNION of
-- LEFT and RIGHT outer joins.
SELECT e.last_name, e.department_id, d.department_name
FROM   employees e
LEFT  JOIN departments d ON e.department_id = d.department_id
WHERE  e.department_id IS NULL
UNION
SELECT e.last_name, d.department_id, d.department_name
FROM   employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
WHERE  e.employee_id IS NULL;

-- ---------------------------------------------------------------------------
-- Three-way join using ANSI JOIN ... ON
-- ---------------------------------------------------------------------------
SELECT e.employee_id, e.last_name, d.department_name, l.city
FROM   employees e
JOIN   departments d ON e.department_id = d.department_id
JOIN   locations   l ON d.location_id  = l.location_id
WHERE  e.department_id IN (90, 60, 100)
ORDER  BY e.department_id, e.last_name;
