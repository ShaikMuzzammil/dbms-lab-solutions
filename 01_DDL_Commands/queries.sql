-- =============================================================================
-- Exercise 01 - DDL Commands: Creation of Table and Simple Queries
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: Practice CREATE, RENAME, ALTER (ADD/MODIFY/DROP/RENAME COLUMN),
--            TRUNCATE and DROP statements.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Self-Activity 1
-- ---------------------------------------------------------------------------

-- 1. Create a table Country with S_No, CountryName, Continent and rename to my_country
CREATE TABLE Country (
    S_No         INT,
    CountryName  CHAR(20),
    Continent    CHAR(20)
);

INSERT INTO Country VALUES
 (1, 'India',         'Asia'),
 (2, 'United States', 'North America'),
 (3, 'Egypt',         'Africa');

RENAME TABLE Country TO my_country;

-- 2. Add a column Language and populate the column
ALTER TABLE my_country ADD COLUMN Language CHAR(20);

UPDATE my_country SET Language = 'Hindi'    WHERE S_No = 1;
UPDATE my_country SET Language = 'English'  WHERE S_No = 2;
UPDATE my_country SET Language = 'Egyptian' WHERE S_No = 3;

-- 3. Change the data type of S_No column to FLOAT
ALTER TABLE my_country MODIFY S_No FLOAT;
SELECT CAST(S_No AS DECIMAL(5,2)) AS S_No,
       CountryName, Continent, Language
FROM   my_country;

-- 4. Drop the column S_No from my_country table
ALTER TABLE my_country DROP COLUMN S_No;
SELECT * FROM my_country;

-- 5. Drop the Language column and add Population(in billion) after CountryName
ALTER TABLE my_country DROP COLUMN Continent;
ALTER TABLE my_country ADD COLUMN `Population_in_billion` INT AFTER CountryName;
ALTER TABLE my_country MODIFY CountryName VARCHAR(25);

UPDATE my_country SET `Population_in_billion` = 140 WHERE CountryName = 'India';
UPDATE my_country SET `Population_in_billion` = 50  WHERE CountryName = 'United States';
UPDATE my_country SET `Population_in_billion` = 20  WHERE CountryName = 'Egypt';

SELECT * FROM my_country;

-- ---------------------------------------------------------------------------
-- Demonstration: TRUNCATE vs DROP
-- ---------------------------------------------------------------------------
CREATE TABLE copy_emp AS SELECT * FROM employees WHERE department_id = 80;
SELECT COUNT(*) AS before_truncate FROM copy_emp;

TRUNCATE TABLE copy_emp;
SELECT COUNT(*) AS after_truncate FROM copy_emp;

DROP TABLE copy_emp;
-- SELECT * FROM copy_emp;  -- would error: table does not exist

-- ---------------------------------------------------------------------------
-- Demonstration: CREATE TABLE ... AS subquery
-- ---------------------------------------------------------------------------
CREATE TABLE dept_90_employees AS
SELECT employee_id, first_name, last_name, salary
FROM   employees
WHERE  department_id = 90;

SELECT * FROM dept_90_employees;

DROP TABLE dept_90_employees;
DROP TABLE my_country;
