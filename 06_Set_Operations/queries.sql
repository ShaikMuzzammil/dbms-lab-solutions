-- =============================================================================
-- Exercise 06 - Using Set Operators
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: UNION, UNION ALL, INTERSECT, MINUS / EXCEPT.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- UNION - current and previous job details of all employees (no duplicates)
-- ---------------------------------------------------------------------------
SELECT employee_id, job_id FROM employees
UNION
SELECT employee_id, job_id FROM job_history
ORDER  BY employee_id;

SELECT employee_id, job_id, department_id FROM employees
UNION
SELECT employee_id, job_id, department_id FROM job_history
ORDER  BY employee_id;

-- ---------------------------------------------------------------------------
-- UNION ALL - duplicates preserved, no implicit sort
-- ---------------------------------------------------------------------------
SELECT employee_id, job_id, department_id FROM employees
UNION ALL
SELECT employee_id, job_id, department_id FROM job_history
ORDER  BY employee_id;

-- ---------------------------------------------------------------------------
-- INTERSECT - employees whose current job is the same as their original job
-- ---------------------------------------------------------------------------
SELECT employee_id, job_id FROM employees
INTERSECT
SELECT employee_id, job_id FROM job_history;

SELECT employee_id, job_id, department_id FROM employees
INTERSECT
SELECT employee_id, job_id, department_id FROM job_history;

-- ---------------------------------------------------------------------------
-- MINUS / EXCEPT - employees who have NOT changed jobs even once
-- ---------------------------------------------------------------------------
SELECT employee_id, job_id FROM employees
MINUS
SELECT employee_id, job_id FROM job_history;

-- ---------------------------------------------------------------------------
-- Self-Activity 6 - STUDENT and FACULTY tables
-- ---------------------------------------------------------------------------
CREATE TABLE student (
    FNAME2 VARCHAR(20),
    LNAME2 VARCHAR(20)
);

CREATE TABLE faculty (
    FNAME1 VARCHAR(20),
    LNAME1 VARCHAR(20)
);

INSERT INTO student VALUES
 ('Rajiv',  'chopra'),
 ('Karan',  'Rao'),
 ('Sanjay', 'Krishna'),
 ('Mukesh', 'Singhal');

INSERT INTO faculty VALUES
 ('Aisha',  'Arora'),
 ('Bikash', 'Dutta'),
 ('Makku',  'Singh'),
 ('Rajiv',  'chopra');

-- 1. Remove duplicate rows from the combined list
SELECT FNAME2 AS FNAME, LNAME2 AS LNAME FROM student
UNION
SELECT FNAME1 AS FNAME, LNAME1 AS LNAME FROM faculty
ORDER  BY FNAME;

-- 2. Print last names of students and faculty without removing duplicates
SELECT LNAME2 AS LNAME FROM student
UNION ALL
SELECT LNAME1 AS LNAME FROM faculty;

-- 3. Rows that exist in BOTH student and faculty tables
SELECT FNAME2 AS FNAME, LNAME2 AS LNAME FROM student
INTERSECT
SELECT FNAME1 AS FNAME, LNAME1 AS LNAME FROM faculty;

-- 4. Rows present in student but NOT in faculty (use EXCEPT; MINUS is Oracle)
SELECT FNAME2, LNAME2 FROM student
EXCEPT
SELECT FNAME1, LNAME1 FROM faculty;

-- Cleanup
DROP TABLE student;
DROP TABLE faculty;
