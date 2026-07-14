-- =============================================================================
-- Exercise 10 - PL/SQL
-- Student : Shaik Muzzammil (CH.SC.U4CSE24041)
-- Objective: Anonymous blocks, IF-THEN-ELSE, ELSIF, CASE, LOOP, WHILE LOOP,
--            FOR LOOP, GOTO, procedures, functions.
-- =============================================================================

-- In MySQL, the equivalent of PL/SQL is the stored program (BEGIN ... END)
-- inside a CREATE PROCEDURE / FUNCTION / anonymous block (BEGIN ... END).
-- Below we provide the Oracle PL/SQL syntax (as taught in the worksheet) and
-- the MySQL-compatible equivalent where they differ.
--
-- Before running in Oracle:
--   SQL> SET SERVEROUTPUT ON;
-- Before running in MySQL:
--   mysql> delimiter //
--   ... block ...
--   //

-- ---------------------------------------------------------------------------
-- Example 1 - simple block: read department name by budget
-- ---------------------------------------------------------------------------
-- Oracle:
--   DECLARE
--       A VARCHAR2(20);
--   BEGIN
--       SELECT dept_name INTO A FROM department WHERE budget = 80000;
--       DBMS_OUTPUT.PUT_LINE(A);
--   END;
--   /

-- MySQL equivalent (anonymous block not supported; wrap in a procedure)
DELIMITER //
CREATE PROCEDURE ex1_simple_block()
BEGIN
    DECLARE v_dept_name VARCHAR(30);
    SELECT dept_name INTO v_dept_name FROM department WHERE dept_id = 10;
    SELECT v_dept_name AS dept_name;
END //
DELIMITER ;
CALL ex1_simple_block();

-- ---------------------------------------------------------------------------
-- Example 2 - IF ... THEN ... ELSE ... END IF
-- ---------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ex2_if_then_else()
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    SELECT MAX(salary) INTO v_salary FROM employees;
    IF v_salary > 20000 THEN
        SELECT 'Very high salary' AS result;
    ELSE
        SELECT 'Reasonable salary' AS result;
    END IF;
END //
DELIMITER ;
CALL ex2_if_then_else();

-- ---------------------------------------------------------------------------
-- Example 3 - ELSIF ladder (department size classification)
-- ---------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ex3_elsif()
BEGIN
    DECLARE v_cnt INT;
    SELECT COUNT(*) INTO v_cnt FROM employees WHERE department_id = 50;
    IF v_cnt > 30 THEN
        SELECT CONCAT('Large department: ', v_cnt, ' employees') AS result;
    ELSEIF v_cnt > 10 THEN
        SELECT CONCAT('Medium department: ', v_cnt, ' employees') AS result;
    ELSE
        SELECT CONCAT('Small department: ', v_cnt, ' employees') AS result;
    END IF;
END //
DELIMITER ;
CALL ex3_elsif();

-- ---------------------------------------------------------------------------
-- Example 4 - CASE expression (searched CASE)
-- ---------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ex4_case()
BEGIN
    SELECT last_name, salary,
           CASE
             WHEN salary < 5000  THEN 'Low'
             WHEN salary < 10000 THEN 'Medium'
             WHEN salary < 20000 THEN 'High'
             ELSE 'Very High'
           END AS grade
    FROM   employees
    WHERE  department_id IN (50, 80, 100)
    LIMIT  5;
END //
DELIMITER ;
CALL ex4_case();

-- ---------------------------------------------------------------------------
-- Example 5 - WHILE LOOP (print 1 to 5)
-- ---------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ex5_while_loop()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE msg VARCHAR(255) DEFAULT '';
    WHILE i <= 5 DO
        SET msg = CONCAT(msg, i, ' ');
        SET i = i + 1;
    END WHILE;
    SELECT TRIM(msg) AS countdown;
END //
DELIMITER ;
CALL ex5_while_loop();

-- ---------------------------------------------------------------------------
-- Example 6 - FOR LOOP equivalent (LOOP with counter and EXIT WHEN)
-- ---------------------------------------------------------------------------
-- Oracle: FOR counter IN 1..5 LOOP ... END LOOP;
-- MySQL has no FOR LOOP; we emulate with a simple LOOP and counter.
DELIMITER //
CREATE PROCEDURE ex6_for_loop()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE msg VARCHAR(255) DEFAULT '';
    lbl: LOOP
        SET msg = CONCAT(msg, 'Row ', i, '; ');
        SET i = i + 1;
        IF i > 5 THEN
            LEAVE lbl;
        END IF;
    END LOOP lbl;
    SELECT TRIM(msg) AS for_loop_result;
END //
DELIMITER ;
CALL ex6_for_loop();

-- ---------------------------------------------------------------------------
-- Example 7 - GOTO emulation (loop with conditional exit)
-- ---------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ex7_goto_like()
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    SELECT salary INTO v_salary FROM employees WHERE employee_id = 100;
    IF v_salary > 20000 THEN
        SELECT 'Good' AS result;
    ELSE
        SELECT 'Bad' AS result;
    END IF;
END //
DELIMITER ;
CALL ex7_goto_like();

-- ---------------------------------------------------------------------------
-- Example 8 - PROCEDURE with parameters and exception handling
-- ---------------------------------------------------------------------------
-- Oracle worksheet example uses an ititems table; we use employees.
DELIMITER //
CREATE PROCEDURE update_salary (
    IN p_emp_id INT,
    IN p_raise  DECIMAL(10,2)
)
BEGIN
    DECLARE v_current DECIMAL(10,2);
    DECLARE v_zero_salary CONDITION FOR SQLSTATE '45000';

    SELECT salary INTO v_current FROM employees WHERE employee_id = p_emp_id;

    IF v_current IS NULL THEN
        SIGNAL v_zero_salary SET MESSAGE_TEXT = 'salary is null';
    ELSE
        UPDATE employees
        SET    salary = salary + p_raise
        WHERE  employee_id = p_emp_id;
        SELECT CONCAT('Updated employee ', p_emp_id, ' by ', p_raise) AS result;
    END IF;
END //
DELIMITER ;

CALL update_salary(113, 500);
SELECT employee_id, last_name, salary FROM employees WHERE employee_id = 113;

-- ---------------------------------------------------------------------------
-- Example 9 - FUNCTION that returns a value
-- ---------------------------------------------------------------------------
DELIMITER //
CREATE FUNCTION get_salary (p_emp_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    SELECT salary INTO v_salary FROM employees WHERE employee_id = p_emp_id;
    RETURN v_salary;
END //
DELIMITER ;

SELECT employee_id, last_name, get_salary(employee_id) AS salary_from_fn
FROM   employees
WHERE  department_id = 60;

-- ---------------------------------------------------------------------------
-- Example 10 - Cursor-based loop (bonus: print each department head-count)
-- ---------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ex10_cursor()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_dept_id INT;
    DECLARE v_cnt INT;
    DECLARE cur CURSOR FOR
        SELECT department_id, COUNT(*)
        FROM   employees
        WHERE  department_id IS NOT NULL
        GROUP  BY department_id
        ORDER  BY department_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DROP TEMPORARY TABLE IF EXISTS tmp_dept_counts;
    CREATE TEMPORARY TABLE tmp_dept_counts (department_id INT, head_count INT);

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_dept_id, v_cnt;
        IF done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO tmp_dept_counts VALUES (v_dept_id, v_cnt);
    END LOOP;
    CLOSE cur;

    SELECT * FROM tmp_dept_counts;
    DROP TEMPORARY TABLE tmp_dept_counts;
END //
DELIMITER ;
CALL ex10_cursor();

-- ---------------------------------------------------------------------------
-- Cleanup procedures / functions
-- ---------------------------------------------------------------------------
DROP PROCEDURE ex1_simple_block;
DROP PROCEDURE ex2_if_then_else;
DROP PROCEDURE ex3_elsif;
DROP PROCEDURE ex4_case;
DROP PROCEDURE ex5_while_loop;
DROP PROCEDURE ex6_for_loop;
DROP PROCEDURE ex7_goto_like;
DROP PROCEDURE update_salary;
DROP FUNCTION get_salary;
DROP PROCEDURE ex10_cursor;
