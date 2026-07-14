-- =============================================================================
-- Exercise 03 - SQL Constraints
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, CHECK, DEFAULT,
--            AUTO_INCREMENT; add / drop / disable / enable constraints.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Create MyTable with NOT NULL constraints on UserID, FirstName, LastName
--    JobPosition has no constraint.
-- ---------------------------------------------------------------------------
CREATE TABLE mytable (
    UserID      INT          NOT NULL,
    FirstName   CHAR(20)     NOT NULL,
    LastName    CHAR(20)     NOT NULL,
    JobPosition CHAR(20)
);

DESCRIBE mytable;

-- 2. Alter the table to make JobPosition NOT NULL
ALTER TABLE mytable MODIFY JobPosition CHAR(20) NOT NULL;

DESCRIBE mytable;

-- 3. Make UserID UNIQUE
ALTER TABLE mytable ADD CONSTRAINT uid_unique UNIQUE (UserID);

SHOW CREATE TABLE mytable;

-- 4. Remove the UNIQUE constraint on UserID; add composite UNIQUE UC_MyTab
ALTER TABLE mytable DROP INDEX uid_unique;
ALTER TABLE mytable ADD CONSTRAINT UC_MyTab UNIQUE (UserID, JobPosition);

SHOW CREATE TABLE mytable;

-- 5. Remove UC_MyTab; add composite PRIMARY KEY PK_MyTab on UserID, JobPosition
ALTER TABLE mytable DROP INDEX UC_MyTab;
ALTER TABLE mytable ADD CONSTRAINT PK_MyTab PRIMARY KEY (UserID, JobPosition);

SHOW CREATE TABLE mytable;

-- ---------------------------------------------------------------------------
-- 6. Customer - Orders foreign key relationship
-- ---------------------------------------------------------------------------
CREATE TABLE customer (
    CustomerID INT          NOT NULL PRIMARY KEY,
    Name        VARCHAR(45) NOT NULL,
    Age         INT,
    City        VARCHAR(25)
);

CREATE TABLE orders (
    Order_ID   INT NOT NULL PRIMARY KEY,
    Order_Num  INT NOT NULL,
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
);

SHOW CREATE TABLE customer;
SHOW CREATE TABLE orders;

-- 7. Add VoterID column to MyTable and a CHECK that it is greater than 18
ALTER TABLE mytable ADD COLUMN VoterID INT;
ALTER TABLE mytable ADD CONSTRAINT check_voterid CHECK (VoterID > 18);

SHOW CREATE TABLE mytable;

-- 8. Assign DEFAULT 'Technical' to JobPosition in MyTable
ALTER TABLE mytable MODIFY JobPosition CHAR(20) DEFAULT 'Technical';

SHOW CREATE TABLE mytable;

-- 9. Make UserID AUTO_INCREMENT and insert three rows
--    (PRIMARY KEY constraint must be dropped/re-added in MySQL when changing
--     an existing composite PK; shown here for clarity.)
ALTER TABLE mytable DROP PRIMARY KEY;
ALTER TABLE mytable MODIFY UserID INT AUTO_INCREMENT;
ALTER TABLE mytable ADD PRIMARY KEY (UserID, JobPosition);

INSERT INTO mytable (FirstName, LastName, JobPosition, VoterID) VALUES
 ('Aarav',  'Sharma', 'Technical', 21),
 ('Diya',   'Patel',  'Technical', 25),
 ('Vivaan', 'Reddy',  'Technical', 30);

SELECT * FROM mytable;

-- ---------------------------------------------------------------------------
-- 10. Mov table (Movie Cassette Library)
-- ---------------------------------------------------------------------------
CREATE TABLE mov (
    No     INT,
    Title  VARCHAR(50),
    Type   VARCHAR(15),
    Rating VARCHAR(5),
    Stars  VARCHAR(30),
    Qty    INT,
    Price  DECIMAL(6,2)
);

INSERT INTO mov VALUES
 (1,  'Gone with the Wind',  'Drama',  'G',    'Gable',    4, 39.95),
 (2,  'Friday the 13th',     'Horror', 'R',    'Jason',    2, 69.95),
 (3,  'Top Gun',             'Drama',  'PG',   'Cruise',   7, 49.95),
 (4,  'Splash',              'Comedy', 'PG13', 'Hanks',    3, 29.95),
 (5,  'Independence Day',    'Drama',  'R',    'Turner',   3, 19.95),
 (6,  'Risky Business',      'Comedy', 'R',    'Cruise',   2, 44.95),
 (7,  'Cocoon',              'Scifi',  'PG',   'Ameche',   2, 31.95),
 (8,  'Crocodile Dundee',    'Comedy', 'PG13', 'Harris',   2, 69.95),
 (9,  '101 Dalmatians',      'Comedy', 'G',    'Disney',   3, 59.95),
 (10, 'Tootsie',             'Comedy', 'PG',   'Hoffman',  1, 29.95);

-- (a) Total value of movie cassettes available in the library
SELECT SUM(Qty * Price) AS total_value FROM mov;

-- (b) Movies with Price > 20, sorted by Price
SELECT * FROM mov WHERE Price > 20 ORDER BY Price;

-- (c) Movies sorted by Qty in decreasing order
SELECT Title FROM mov ORDER BY Qty DESC;

-- (d) Replacement value report (Qty*Price*1.15)
SELECT No,
       Qty * Price       AS current_value,
       Qty * Price * 1.15 AS replacement_value
FROM   mov;

-- (e) Count of movies where Rating is not 'G'
SELECT COUNT(*) AS non_g_count FROM mov WHERE Rating <> 'G';

-- (f) Insert a new movie into mov
INSERT INTO mov VALUES
 (11, 'The Matrix', 'Scifi', 'R', 'Reeves', 5, 59.95);

SELECT * FROM mov ORDER BY No;

-- ---------------------------------------------------------------------------
-- 11. DOCTOR and SALARY tables
-- ---------------------------------------------------------------------------
CREATE TABLE doctor (
    ID         INT,
    Name       VARCHAR(40),
    Dept       VARCHAR(20),
    Sex        CHAR(1),
    Experience INT
);

CREATE TABLE salary (
    SalaryID      INT,
    Basic         INT,
    Allowance     INT,
    Consultation  INT
);

INSERT INTO doctor VALUES
 (101, 'John',    'ENT',         'M', 12),
 (104, 'Smith',   'ORTHOPEDIC',  'M',  5),
 (107, 'George',  'CARDIOLOGY',  'M', 10),
 (114, 'Lara',    'SKIN',        'F',  3),
 (109, 'K George','MEDICINE',    'F',  9),
 (105, 'Johnson', 'ORTHOPEDIC',  'M', 10),
 (117, 'Lucy',    'ENT',         'F',  3),
 (118, 'Billy',   'MEDICINE',    'F', 12),
 (130, 'Morphy',  'ORTHOPEDIC',  'M', 15);

INSERT INTO salary VALUES
 (101, 12000, 1000, 300),
 (104, 23000, 2300, 500),
 (107, 32000, 4000, 500),
 (114, 12000, 5200, 100),
 (109, 42000, 1700, 200),
 (105, 18900, 1690, 300),
 (130, 21700, 2600, 300);

-- 11.1 Doctors in MEDICINE having more than 10 years experience
SELECT Name FROM doctor WHERE Dept = 'MEDICINE' AND Experience > 10;

-- 11.2 Average salary of doctors working in ENT  (Salary = Basic + Allowance)
SELECT AVG(Basic + Allowance) AS average_salary
FROM   doctor d JOIN salary s ON d.ID = s.SalaryID
WHERE  d.Dept = 'ENT';

-- 11.3 Minimum allowance of female doctors
SELECT MIN(Allowance) AS minimum_allowance
FROM   doctor d JOIN salary s ON d.ID = s.SalaryID
WHERE  d.Sex = 'F';

-- 11.4 Highest consultation fee among male doctors
SELECT MAX(Consultation) AS maximum_consultation
FROM   doctor d JOIN salary s ON d.ID = s.SalaryID
WHERE  d.Sex = 'M';

-- 11.5 Group by Sex and count male and female doctors
SELECT Sex, COUNT(*) AS doctor_count
FROM   doctor
GROUP  BY Sex;

-- 11.6 Group by Sex and find average salary
SELECT d.Sex, AVG(Basic + Allowance) AS average_salary
FROM   doctor d JOIN salary s ON d.ID = s.SalaryID
GROUP  BY d.Sex;

-- ---------------------------------------------------------------------------
-- Viewing constraints and constraint columns (MySQL metadata)
-- ---------------------------------------------------------------------------
SELECT constraint_name, constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = 'mytable';

SELECT constraint_name, column_name
FROM   information_schema.key_column_usage
WHERE  table_name = 'mytable';

-- Cleanup (run only when you want to start over)
-- DROP TABLE orders;
-- DROP TABLE customer;
-- DROP TABLE mov;
-- DROP TABLE salary;
-- DROP TABLE doctor;
-- DROP TABLE mytable;
