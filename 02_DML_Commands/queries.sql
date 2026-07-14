-- =============================================================================
-- Exercise 02 - DML Commands: Manipulating Data
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: INSERT, UPDATE, DELETE, basic SELECT, NULL handling, copy rows.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- INSERT - basic syntax (single row)
-- ---------------------------------------------------------------------------
INSERT INTO department VALUES
 (70, 'Public Relations', 204, 2700);

-- Insert with NULL values - implicit (omit the column)
INSERT INTO department (dept_id, dept_name) VALUES
 (30, 'Purchasing'),
 (45, 'Training');

-- Insert with NULL values - explicit (NULL keyword)
INSERT INTO department VALUES
 (100, 'Finance', NULL, NULL);

SELECT * FROM department ORDER BY dept_id;

-- ---------------------------------------------------------------------------
-- Insert with special values (SYSDATE) and specific date
-- ---------------------------------------------------------------------------
CREATE TABLE emp_demo AS SELECT * FROM employees WHERE 1 = 0;

INSERT INTO emp_demo VALUES
 (113, 'Louis', 'Popp', 'LPOPP', '515.124.4567',
  SYSDATE, 'AC_ACCOUNT', 6900, NULL, 205, 100);

INSERT INTO emp_demo VALUES
 (114, 'Den', 'Raphealy', 'DRAPHEAL', '515.127.4561',
  TO_DATE('Feb 3, 1999', 'Mon, DD, YYYY'),
  'AC_ACCOUNT', 11000, 100, 30, 100);

SELECT employee_id, first_name, hire_date FROM emp_demo;

-- ---------------------------------------------------------------------------
-- Insert multiple rows in one statement
-- ---------------------------------------------------------------------------
INSERT INTO department VALUES
 (200, 'Operations',    NULL, 1700),
 (210, 'IT Support',    NULL, 1700),
 (220, 'NOC',           NULL, 1700);

SELECT * FROM department WHERE dept_id IN (200, 210, 220);

-- ---------------------------------------------------------------------------
-- Copying rows from another table using a subquery
-- ---------------------------------------------------------------------------
CREATE TABLE sales_reps AS
SELECT employee_id AS id, last_name AS name, salary, commission_pct
FROM   employees
WHERE  job_id LIKE '%REP';

SELECT * FROM sales_reps ORDER BY id LIMIT 5;

-- ---------------------------------------------------------------------------
-- UPDATE - specific rows and all rows
-- ---------------------------------------------------------------------------
UPDATE employees
SET    email = 'not available'
WHERE  department_id = 90;

SELECT employee_id, last_name, email FROM employees WHERE department_id = 90;

UPDATE department
SET    location_id = 1700
WHERE  location_id IS NULL;

SELECT * FROM department ORDER BY dept_id;

-- Update using a subquery
UPDATE emp_demo
SET    job_id = (SELECT job_id FROM employees WHERE employee_id = 205)
WHERE  employee_id = 114;

SELECT employee_id, job_id FROM emp_demo;

-- ---------------------------------------------------------------------------
-- DELETE
-- ---------------------------------------------------------------------------
DELETE FROM department WHERE dept_name = 'Finance';

SELECT * FROM department ORDER BY dept_id;

DELETE FROM emp_demo;
SELECT COUNT(*) AS emp_demo_count FROM emp_demo;

-- Cleanup
DROP TABLE emp_demo;
DROP TABLE sales_reps;

-- Final view of the department table after all DML activity
SELECT * FROM department ORDER BY dept_id;
