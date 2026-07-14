-- =============================================================================
-- Exercise 04 - Arithmetic / Logical Operations, Sorting and Grouping
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: Arithmetic expressions, column aliases, DISTINCT, comparison and
--            logical operators, ORDER BY, NULL handling.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Arithmetic expressions
-- ---------------------------------------------------------------------------
SELECT last_name, salary, salary + 300 FROM employees;

SELECT last_name, salary, 12 * (salary + 100) AS annual_salary_plus_bonus
FROM   employees;

-- Column alias (AS keyword)
SELECT last_name AS "Employee Name", salary AS "Monthly Salary"
FROM   employees
WHERE  department_id = 50;

-- Concatenation operator (Oracle ||; in MySQL use CONCAT)
SELECT CONCAT(first_name, ' ', last_name) AS full_name, salary
FROM   employees
WHERE  department_id = 80
LIMIT  5;

-- Literal character string
SELECT CONCAT(first_name, ' ', last_name, ' works in department ', department_id) AS description
FROM   employees
WHERE  department_id IN (90, 60)
LIMIT  5;

-- ---------------------------------------------------------------------------
-- DISTINCT - eliminate duplicates
-- ---------------------------------------------------------------------------
SELECT DISTINCT department_id FROM employees ORDER BY department_id;

SELECT DISTINCT job_id, department_id FROM employees ORDER BY job_id;

-- ---------------------------------------------------------------------------
-- Comparison conditions
-- ---------------------------------------------------------------------------
SELECT last_name, salary
FROM   employees
WHERE  salary <= 3000;

SELECT last_name, salary
FROM   employees
WHERE  salary BETWEEN 5000 AND 10000;

SELECT last_name, department_id
FROM   employees
WHERE  department_id IN (20, 50, 80);

SELECT last_name
FROM   employees
WHERE  last_name LIKE 'S%';

SELECT last_name
FROM   employees
WHERE  last_name LIKE '_a%';

-- Test for NULL
SELECT last_name, manager_id
FROM   employees
WHERE  manager_id IS NULL;

SELECT last_name, commission_pct
FROM   employees
WHERE  commission_pct IS NOT NULL
LIMIT  5;

-- ---------------------------------------------------------------------------
-- Rules of precedence (AND before OR)
-- ---------------------------------------------------------------------------
SELECT last_name, job_id, salary
FROM   employees
WHERE  job_id = 'SA_REP'
   OR  job_id = 'AD_PRES'
   AND salary > 15000;

-- Use parentheses to override precedence
SELECT last_name, job_id, salary
FROM   employees
WHERE  (job_id = 'SA_REP' OR job_id = 'AD_PRES')
   AND salary > 15000;

-- ---------------------------------------------------------------------------
-- ORDER BY - sorting rows
-- ---------------------------------------------------------------------------
SELECT last_name, salary
FROM   employees
WHERE  department_id = 80
ORDER  BY salary DESC;

SELECT last_name, salary
FROM   employees
ORDER  BY salary;

-- Sort by column alias
SELECT last_name, salary * 12 AS annual_salary
FROM   employees
WHERE  department_id = 50
ORDER  BY annual_salary DESC
LIMIT  5;

-- Sort by multiple columns
SELECT last_name, department_id, salary
FROM   employees
ORDER  BY department_id, salary DESC;

-- ---------------------------------------------------------------------------
-- Self-Activity 4 (worksheet): list 5 columns from employees in different
-- sort orders, plus arithmetic on salary.
-- ---------------------------------------------------------------------------
-- (a) Employees whose salary is greater than the average salary of dept 80
SELECT last_name, salary
FROM   employees
WHERE  salary > (SELECT AVG(salary) FROM employees WHERE department_id = 80)
ORDER  BY salary DESC
LIMIT  10;

-- (b) Number of employees hired each year, sorted by year
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS hires
FROM   employees
GROUP  BY hire_year
ORDER  BY hire_year;

-- (c) Employees whose first name starts with a vowel, sorted by last name
SELECT first_name, last_name
FROM   employees
WHERE  first_name REGEXP '^[AEIOU]'
ORDER  BY last_name;

-- (d) For each department, show the highest and lowest salary
SELECT department_id,
       MAX(salary) AS highest,
       MIN(salary) AS lowest
FROM   employees
WHERE  department_id IS NOT NULL
GROUP  BY department_id
ORDER  BY department_id;

-- (e) Employees with no commission, ordered by salary descending
SELECT last_name, salary, commission_pct
FROM   employees
WHERE  commission_pct IS NULL
ORDER  BY salary DESC
LIMIT  10;
