-- =============================================================================
-- Exercise 07 - Aggregate Functions
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: AVG, COUNT, MAX, MIN, STDDEV, SUM, VARIANCE; GROUP BY; HAVING.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Basic aggregates over the whole table
-- ---------------------------------------------------------------------------
SELECT AVG(salary) AS avg_sal,
       SUM(salary) AS sum_sal,
       MIN(salary) AS min_sal,
       MAX(salary) AS max_sal,
       COUNT(*)    AS row_cnt,
       COUNT(employee_id) AS emp_cnt,
       COUNT(DISTINCT department_id) AS dept_cnt
FROM   employees;

-- Average and sum of salaries per department
SELECT department_id,
       AVG(salary) AS avg_sal,
       SUM(salary) AS sum_sal
FROM   employees
WHERE  department_id IS NOT NULL
GROUP  BY department_id
ORDER  BY department_id;

-- MIN and MAX salaries per job
SELECT job_id, MIN(salary) AS min_sal, MAX(salary) AS max_sal
FROM   employees
GROUP  BY job_id
ORDER  BY job_id;

-- COUNT function variants
SELECT COUNT(*)                  AS all_rows,
       COUNT(commission_pct)     AS non_null_comm,
       COUNT(DISTINCT manager_id) AS distinct_mgrs
FROM   employees;

-- Group functions and NULL values
SELECT AVG(commission_pct) AS avg_comm_with_nulls,
       AVG(NVL(commission_pct, 0)) AS avg_comm_zero_filled
FROM   employees;

-- ---------------------------------------------------------------------------
-- GROUP BY with multiple columns
-- ---------------------------------------------------------------------------
SELECT department_id, job_id,
       COUNT(*)  AS emp_cnt,
       AVG(salary) AS avg_sal
FROM   employees
WHERE  department_id IS NOT NULL
GROUP  BY department_id, job_id
ORDER  BY department_id, job_id;

-- ---------------------------------------------------------------------------
-- Illegal query: a non-aggregated column in SELECT is not in GROUP BY
-- (This will raise an error - shown for teaching purposes.)
-- ---------------------------------------------------------------------------
-- SELECT department_id, last_name, AVG(salary) FROM employees GROUP BY department_id;

-- Correct version
SELECT department_id, COUNT(*) AS emp_cnt
FROM   employees
GROUP  BY department_id;

-- ---------------------------------------------------------------------------
-- HAVING - restrict groups
-- ---------------------------------------------------------------------------
-- Maximum salary per department, only departments whose max > 10000
SELECT department_id, MAX(salary) AS max_sal
FROM   employees
WHERE  department_id IS NOT NULL
GROUP  BY department_id
HAVING MAX(salary) > 10000
ORDER  BY max_sal DESC;

-- Average salary per job, only those whose average > 8000
SELECT job_id, AVG(salary) AS avg_sal
FROM   employees
GROUP  BY job_id
HAVING AVG(salary) > 8000
ORDER  BY avg_sal DESC;

-- Total head count per department, only those with more than 5 employees
SELECT department_id, COUNT(*) AS emp_cnt
FROM   employees
WHERE  department_id IS NOT NULL
GROUP  BY department_id
HAVING COUNT(*) > 5
ORDER  BY emp_cnt DESC;

-- ---------------------------------------------------------------------------
-- Nesting group functions (MAX of AVG)
-- ---------------------------------------------------------------------------
-- Maximum department average salary (single value)
SELECT MAX(AVG(salary)) AS max_dept_avg
FROM   employees
GROUP  BY department_id;

-- Equivalent two-step formulation that works in MySQL 8:
SELECT MAX(avg_sal) AS max_dept_avg
FROM (
    SELECT AVG(salary) AS avg_sal
    FROM   employees
    GROUP  BY department_id
) t;

-- ---------------------------------------------------------------------------
-- HAVING with subquery (departments whose minimum salary is greater than
-- the minimum salary of department 50)
-- ---------------------------------------------------------------------------
SELECT department_id, MIN(salary) AS min_sal
FROM   employees
GROUP  BY department_id
HAVING MIN(salary) > (SELECT MIN(salary) FROM employees WHERE department_id = 50)
ORDER  BY department_id;
