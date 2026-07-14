-- =============================================================================
-- Exercise 09 - SQL Subqueries
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: Single-row, multiple-row, and correlated subqueries in WHERE,
--            HAVING and FROM clauses; IN, ANY, ALL operators.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Single-row subquery
-- ---------------------------------------------------------------------------
-- Employees who earn more than Abel
SELECT last_name, salary
FROM   employees
WHERE  salary > (SELECT salary FROM employees WHERE last_name = 'Abel')
ORDER  BY salary DESC;

-- Employees whose job ID is the same as employee 141
SELECT last_name, job_id
FROM   employees
WHERE  job_id = (SELECT job_id FROM employees WHERE employee_id = 141);

-- Employees whose job ID is the same as employee 141 AND whose salary is
-- greater than employee 143's salary.
SELECT last_name, job_id, salary
FROM   employees
WHERE  job_id = (SELECT job_id FROM employees WHERE employee_id = 141)
  AND  salary > (SELECT salary FROM employees WHERE employee_id = 143);

-- ---------------------------------------------------------------------------
-- Group functions inside a subquery
-- ---------------------------------------------------------------------------
-- Employees whose salary equals the minimum salary
SELECT last_name, job_id, salary
FROM   employees
WHERE  salary = (SELECT MIN(salary) FROM employees);

-- ---------------------------------------------------------------------------
-- HAVING with subquery - departments whose minimum salary is greater than
-- the minimum salary of department 50.
-- ---------------------------------------------------------------------------
SELECT department_id, MIN(salary) AS min_sal
FROM   employees
GROUP  BY department_id
HAVING MIN(salary) > (SELECT MIN(salary) FROM employees WHERE department_id = 50)
ORDER  BY department_id;

-- Job with the lowest average salary (nesting aggregates)
SELECT job_id, AVG(salary) AS avg_sal
FROM   employees
GROUP  BY job_id
HAVING AVG(salary) = (SELECT MIN(avg_sal)
                      FROM  (SELECT AVG(salary) AS avg_sal
                             FROM   employees
                             GROUP  BY job_id) t);

-- ---------------------------------------------------------------------------
-- Multiple-row subqueries
-- ---------------------------------------------------------------------------
-- Employees who earn the same salary as the minimum salary for some department
SELECT last_name, salary, department_id
FROM   employees
WHERE  salary IN (SELECT MIN(salary) FROM employees GROUP BY department_id)
ORDER  BY salary, last_name;

-- ANY operator - employees who are NOT IT_PROG and whose salary is less than
-- that of ANY IT programmer (i.e. less than the max IT_PROG salary).
SELECT employee_id, last_name, job_id, salary
FROM   employees
WHERE  salary < ANY (SELECT salary FROM employees WHERE job_id = 'IT_PROG')
  AND  job_id <> 'IT_PROG'
ORDER  BY salary DESC;

-- ALL operator - employees whose salary is less than ALL IT_PROG salaries
-- (i.e. less than the minimum IT_PROG salary).
SELECT employee_id, last_name, job_id, salary
FROM   employees
WHERE  salary < ALL (SELECT salary FROM employees WHERE job_id = 'IT_PROG')
  AND  job_id <> 'IT_PROG'
ORDER  BY salary DESC;

-- ---------------------------------------------------------------------------
-- Correlated subquery - employees who manage at least one other employee
-- ---------------------------------------------------------------------------
SELECT emp.last_name
FROM   employees emp
WHERE  emp.employee_id IN (SELECT mgr.manager_id FROM employees mgr);

-- Employees who do NOT manage anyone (NOT IN with NULL handling)
SELECT last_name
FROM   employees
WHERE  employee_id NOT IN (
       SELECT manager_id FROM employees WHERE manager_id IS NOT NULL)
LIMIT  10;

-- ---------------------------------------------------------------------------
-- Subquery in the FROM clause (inline view)
-- ---------------------------------------------------------------------------
SELECT d.department_name, t.avg_sal
FROM   departments d
JOIN  (SELECT department_id, AVG(salary) AS avg_sal
       FROM   employees
       GROUP  BY department_id) t
       ON d.department_id = t.department_id
ORDER  BY t.avg_sal DESC
LIMIT  5;

-- ---------------------------------------------------------------------------
-- Self-Activity 9 - Orchestras dataset
-- ---------------------------------------------------------------------------
CREATE TABLE orchestras (
    id            INT PRIMARY KEY,
    name          VARCHAR(50),
    rating        INT,
    city_origin   VARCHAR(40),
    country_origin VARCHAR(40),
    year_founded  INT
);

CREATE TABLE concerts (
    id            INT PRIMARY KEY,
    city          VARCHAR(40),
    country       VARCHAR(40),
    year          INT,
    rating        INT,
    orchestra_id  INT,
    FOREIGN KEY (orchestra_id) REFERENCES orchestras(id)
);

CREATE TABLE members (
    id            INT PRIMARY KEY,
    name          VARCHAR(50),
    position      VARCHAR(40),
    wage          INT,
    experience    INT,
    orchestra_id  INT,
    FOREIGN KEY (orchestra_id) REFERENCES orchestras(id)
);

INSERT INTO orchestras VALUES
 (1, 'Berlin Philharmonic',     10, 'Berlin',     'Germany',     1882),
 (2, 'Vienna Philharmonic',     10, 'Vienna',     'Austria',     1842),
 (3, 'New York Philharmonic',    9, 'New York',   'USA',         1842),
 (4, 'London Symphony Orchestra',9, 'London',     'UK',          1904),
 (5, 'Chennai Symphony',         7, 'Chennai',    'India',       1985);

INSERT INTO concerts VALUES
 (101, 'Berlin',   'Germany', 2023, 10, 1),
 (102, 'Vienna',   'Austria', 2023, 10, 2),
 (103, 'New York', 'USA',     2022,  9, 3),
 (104, 'London',   'UK',      2022,  9, 4),
 (105, 'Chennai',  'India',   2024,  8, 5),
 (106, 'Berlin',   'Germany', 2024, 10, 1),
 (107, 'Tokyo',    'Japan',   2023,  7, 1);

INSERT INTO members VALUES
 (1, 'Anna Schmidt',   'Violin',   50000, 12, 1),
 (2, 'Hans Mueller',   'Cello',    45000, 10, 1),
 (3, 'Greta Wagner',   'Flute',    40000,  8, 1),
 (4, 'Karl Schmidt',   'Viola',    42000,  9, 2),
 (5, 'Lena Fischer',   'Violin',   48000, 11, 2),
 (6, 'John Smith',     'Trumpet',  43000,  7, 3),
 (7, 'Emily Davis',    'Violin',   39000,  6, 3),
 (8, 'James Brown',    'Cello',    41000,  8, 4),
 (9, 'Priya Iyer',     'Violin',   25000,  4, 5),
 (10,'Rahul Nair',     'Mridangam',23000,  5, 5);

-- 1. Orchestras whose city of origin has hosted a concert
SELECT name
FROM   orchestras
WHERE  city_origin IN (SELECT city FROM concerts)
ORDER  BY name;

-- 2. Members who earn more than the average wage of their orchestra
SELECT m.name, m.wage, m.orchestra_id
FROM   members m
WHERE  m.wage > (SELECT AVG(wage)
                 FROM   members
                 WHERE  orchestra_id = m.orchestra_id)
ORDER  BY m.orchestra_id, m.wage DESC;

-- 3. Orchestras that have never had a concert outside their country of origin
SELECT name
FROM   orchestras o
WHERE  o.id NOT IN (SELECT c.orchestra_id
                    FROM   concerts c
                    WHERE  c.country <> o.country_origin);

-- 4. The highest-rated orchestra (using a correlated subquery)
SELECT name, rating
FROM   orchestras o
WHERE  o.rating = (SELECT MAX(rating) FROM orchestras);

-- 5. Members whose orchestra was founded before 1900
SELECT m.name AS member_name, o.name AS orchestra_name, o.year_founded
FROM   members m
JOIN   orchestras o ON m.orchestra_id = o.id
WHERE  o.id IN (SELECT id FROM orchestras WHERE year_founded < 1900)
ORDER  BY m.name;

-- Cleanup
DROP TABLE members;
DROP TABLE concerts;
DROP TABLE orchestras;
