-- =============================================================================
-- Exercise 05 - Built-in Functions
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: Single-row functions - character, number, date, conversion.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Character / string functions
-- ---------------------------------------------------------------------------
SELECT LOWER(last_name)   AS lower_name,
       UPPER(last_name)   AS upper_name,
       INITCAP(last_name) AS initcap_name
FROM   employees
WHERE  department_id = 90;

SELECT last_name,
       LENGTH(last_name) AS name_len,
       SUBSTR(last_name, 1, 3) AS first_three,
       INSTR(last_name, 'a')   AS first_a_pos
FROM   employees
WHERE  department_id = 60;

SELECT last_name,
       CONCAT(first_name, ' ', last_name) AS full_name,
       RPAD(last_name, 12, '.') AS padded
FROM   employees
WHERE  department_id IN (50, 80)
LIMIT  6;

SELECT last_name,
       TRIM('  ' || last_name || '  ') AS trimmed_name,
       REPLACE(last_name, 'a', 'A')    AS replace_a
FROM   employees
WHERE  department_id = 100;

-- ---------------------------------------------------------------------------
-- Number functions
-- ---------------------------------------------------------------------------
SELECT ROUND(45.923, 2) AS round_2,
       ROUND(45.923, 0) AS round_0,
       ROUND(45.923, -1) AS round_neg1,
       TRUNC(45.923, 2) AS trunc_2,
       TRUNC(45.923)    AS trunc_0,
       MOD(1600, 300)   AS mod_result,
       CEIL(45.1)       AS ceil_v,
       FLOOR(45.9)      AS floor_v;

SELECT last_name, salary,
       ROUND(salary, -2) AS rounded_to_hundred,
       MOD(salary, 1000) AS remainder_after_1000
FROM   employees
WHERE  department_id = 80
LIMIT  5;

-- ---------------------------------------------------------------------------
-- Date functions
-- ---------------------------------------------------------------------------
SELECT SYSDATE       AS today,
       CURRENT_DATE  AS current_date,
       CURRENT_TIMESTAMP AS current_ts;

-- Day arithmetic (Oracle: +n; MySQL: DATE_ADD)
SELECT employee_id, hire_date,
       hire_date + 1 AS plus_one_day,
       hire_date - 7 AS minus_one_week,
       ADD_MONTHS(hire_date, 6) AS plus_6_months,
       MONTHS_BETWEEN(SYSDATE, hire_date) AS months_employed
FROM   employees
WHERE  department_id = 60;

SELECT last_name,
       hire_date,
       EXTRACT(YEAR  FROM hire_date) AS hire_year,
       EXTRACT(MONTH FROM hire_date) AS hire_month,
       EXTRACT(DAY   FROM hire_date) AS hire_day
FROM   employees
WHERE  department_id = 100;

-- ---------------------------------------------------------------------------
-- Conversion functions
-- ---------------------------------------------------------------------------
-- TO_CHAR (Oracle); MySQL uses DATE_FORMAT. We show the worksheet's Oracle
-- syntax and the equivalent MySQL call.
SELECT last_name,
       TO_CHAR(hire_date, 'DD-Mon-YYYY')    AS oracle_format,
       DATE_FORMAT(hire_date, '%d-%b-%Y')   AS mysql_format
FROM   employees
WHERE  department_id = 90;

SELECT last_name, salary,
       TO_CHAR(salary, '$99,999.99')          AS oracle_money,
       FORMAT(salary, 2)                       AS mysql_money
FROM   employees
WHERE  department_id = 80
LIMIT  5;

-- TO_NUMBER / TO_DATE
SELECT TO_NUMBER('1234.56', '9999.99') AS oracle_to_num,
       CAST('1234.56' AS DECIMAL(10,2)) AS mysql_to_num,
       TO_DATE('Feb 3, 1999', 'Mon, DD, YYYY') AS oracle_to_date,
       STR_TO_DATE('Feb 3, 1999', '%b %d, %Y') AS mysql_to_date;

-- ---------------------------------------------------------------------------
-- Implicit conversion (numbers and dates can be compared as strings)
-- ---------------------------------------------------------------------------
SELECT last_name, hire_date
FROM   employees
WHERE  hire_date > '1998-01-01'
LIMIT  5;

-- ---------------------------------------------------------------------------
-- Coalesce / NVL / NULLIF
-- ---------------------------------------------------------------------------
SELECT last_name, salary, commission_pct,
       NVL(commission_pct, 0) AS comm_nvl,
       COALESCE(commission_pct, 0) AS comm_coalesce,
       salary * (1 + NVL(commission_pct, 0)) AS total_comp
FROM   employees
WHERE  department_id = 80
LIMIT  5;

SELECT last_name, salary, commission_pct,
       NULLIF(salary, commission_pct * 1000) AS nullif_demo
FROM   employees
WHERE  department_id = 80
LIMIT  3;

-- ---------------------------------------------------------------------------
-- CASE expression
-- ---------------------------------------------------------------------------
SELECT last_name, salary,
       CASE
         WHEN salary < 5000  THEN 'Low'
         WHEN salary < 10000 THEN 'Medium'
         WHEN salary < 20000 THEN 'High'
         ELSE 'Very High'
       END AS salary_grade
FROM   employees
WHERE  department_id IN (50, 80, 100)
LIMIT  10;
