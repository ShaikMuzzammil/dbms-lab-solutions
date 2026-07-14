-- =============================================================================
-- Exercise 11 - Views, Synonyms, Index, Sequence
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: CREATE / ALTER / DROP VIEW; CREATE SYNONYM (MySQL: alias via
--            VIEW); CREATE SEQUENCE (MySQL: AUTO_INCREMENT); CREATE INDEX.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Setup the student table used in this exercise
-- ---------------------------------------------------------------------------
CREATE TABLE student (
    regno  INT,
    name   VARCHAR(20),
    mark1  INT,
    mark2  INT,
    total  INT
);

INSERT INTO student VALUES
 (130, 'ajay', 90, 90, 180),
 (126, 'aldo', 95, 96, 191),
 ( 76, 'guru', 90, 95, 185);

-- ---------------------------------------------------------------------------
-- VIEW - simple
-- ---------------------------------------------------------------------------
CREATE VIEW studentdetail AS
SELECT regno, name, mark1 FROM student;

SELECT * FROM studentdetail;

-- 1. Create a view student_total showing regno, name, total from student.
CREATE VIEW student_total AS
SELECT regno, name, total FROM student;

SELECT * FROM student_total;

-- Alter the view studentdetail to include mark2
CREATE OR REPLACE VIEW studentdetail AS
SELECT regno, name, mark1, mark2 FROM student;

SELECT * FROM studentdetail;

-- Drop the studentdetail view
DROP VIEW studentdetail;

-- ---------------------------------------------------------------------------
-- SYNONYM (MySQL does not support CREATE SYNONYM; emulate with a VIEW)
-- ---------------------------------------------------------------------------
CREATE TABLE employee_details (
    id    INT PRIMARY KEY,
    name  VARCHAR(40),
    dept  VARCHAR(20)
);

INSERT INTO employee_details VALUES
 (1, 'Alice', 'HR'),
 (2, 'Bob',   'IT'),
 (3, 'Carol', 'Sales');

-- Create an alias 'emp' for employee_details via a view
CREATE VIEW emp AS SELECT * FROM employee_details;

-- Insert and select data using emp
INSERT INTO emp (id, name, dept) VALUES (4, 'David', 'Finance');
SELECT * FROM emp;

-- Drop the synonym (view)
DROP VIEW emp;
DROP TABLE employee_details;

-- ---------------------------------------------------------------------------
-- SEQUENCE (MySQL: AUTO_INCREMENT)
-- ---------------------------------------------------------------------------
-- Oracle worksheet syntax (for reference):
--   CREATE SEQUENCE student_seq START WITH 100 INCREMENT BY 1;
--   INSERT INTO student VALUES (student_seq.NEXTVAL, 'raja', 'pass');
--
-- MySQL equivalent: use AUTO_INCREMENT column
CREATE TABLE employee (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20)
);

-- The worksheet's example creates emp_seq starting at 500, incrementing by 5.
-- In MySQL we set AUTO_INCREMENT = 500 and use a BEFORE INSERT trigger to
-- increment by 5 (since AUTO_INCREMENT always increments by 1 by default).
ALTER TABLE employee AUTO_INCREMENT = 500;

DELIMITER //
CREATE TRIGGER emp_seq_trigger
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    IF NEW.id IS NULL THEN
        SET NEW.id = (SELECT COALESCE(MAX(id), 495) + 5 FROM employee);
    END IF;
END //
DELIMITER ;

INSERT INTO employee (name) VALUES ('raja');
INSERT INTO employee (name) VALUES ('ravi');
INSERT INTO employee (name) VALUES ('mira');

SELECT * FROM employee;

DROP TRIGGER emp_seq_trigger;
DROP TABLE employee;

-- ---------------------------------------------------------------------------
-- INDEX
-- ---------------------------------------------------------------------------
CREATE TABLE book (
    book_id INT,
    title   VARCHAR(50),
    author  VARCHAR(30)
);

INSERT INTO book VALUES
 (1, 'Database System Concepts', 'Silberschatz'),
 (2, 'SQL for Beginners',        'Muller'),
 (3, 'Clean Code',               'Martin');

-- Create an index on the author column
CREATE INDEX author_idx ON book (author);

-- Verify the index exists
SHOW INDEX FROM book;

-- Query that benefits from the index
SELECT * FROM book WHERE author = 'Muller';

-- Drop the index
DROP INDEX author_idx ON book;
SHOW INDEX FROM book;

-- Cleanup
DROP TABLE book;
DROP TABLE student;
