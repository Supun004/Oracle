--scirpt to test proc_suspend_Single_Course
DECLARE
  IN_STUDENT_ID NUMBER;
  IN_SECTION_ID NUMBER;
  IN_START_DATE DATE;
  IN_SUSPEND_PERIOD NUMBER;
BEGIN
  IN_STUDENT_ID := 400;
  IN_SECTION_ID := 86;
  IN_START_DATE := sysdate;
  IN_SUSPEND_PERIOD := 1;

  PROC_SUSPEND_SINGLE_COURSE(
    IN_STUDENT_ID => IN_STUDENT_ID,
    IN_SECTION_ID => IN_SECTION_ID,
    IN_START_DATE => IN_START_DATE,
    IN_SUSPEND_PERIOD => IN_SUSPEND_PERIOD
  );
--rollback; 
END;
/
--test case 1
INSERT INTO student VALUES (400,'Mr.','Test','Test','101-09 120th St.','11419','718-555-5555','Albert Hildegard Co.','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO enrollment VALUES (400,86,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO grade VALUES (400,86,'FI',1,85,NULL,'CBRENNAN',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'JAYCAF',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));
COMMIT;
select * from student where student_id = 400;
select * from enrollment where student_id = 400;
select * from grade where student_id = 400;

select * from student_log where student_id = 400;
select * from enrollment_log where student_id = 400;
select *  from STUDENT_COURSE_SUSPENSION;


--test case 2

DECLARE
  IN_STUDENT_ID NUMBER;
  IN_SECTION_ID NUMBER;
  IN_START_DATE DATE;
  IN_SUSPEND_PERIOD NUMBER;
BEGIN
  IN_STUDENT_ID := 202;
  IN_SECTION_ID := 105;
  IN_START_DATE := sysdate;
  IN_SUSPEND_PERIOD := 1;

  PROC_SUSPEND_SINGLE_COURSE(
    IN_STUDENT_ID => IN_STUDENT_ID,
    IN_SECTION_ID => IN_SECTION_ID,
    IN_START_DATE => IN_START_DATE,
    IN_SUSPEND_PERIOD => IN_SUSPEND_PERIOD
  );
--rollback; 
END;
/

-- test case 03
--Student Not attended any assignment
INSERT INTO student VALUES (400,'Mr.','Test','Test','101-09 120th St.','11419','718-555-5555','Albert Hildegard Co.','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO enrollment VALUES (400,86,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
Commit;


--Test Case 04: Student not allowed to suspend more than two years
INSERT INTO student VALUES (400,'Mr.','Test','Test','101-09 120th St.','11419','718-555-5555','Albert Hildegard Co.','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO enrollment VALUES (400,86,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO grade VALUES (400,86,'FI',1,85,NULL,'CBRENNAN',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'JAYCAF',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));
COMMIT;

DECLARE
  IN_STUDENT_ID NUMBER;
  IN_SECTION_ID NUMBER;
  IN_START_DATE DATE;
  IN_SUSPEND_PERIOD NUMBER;
BEGIN
  IN_STUDENT_ID := 400;
  IN_SECTION_ID := 86;
  IN_START_DATE := sysdate;
  IN_SUSPEND_PERIOD := 2;

  PROC_SUSPEND_SINGLE_COURSE(
    IN_STUDENT_ID => IN_STUDENT_ID,
    IN_SECTION_ID => IN_SECTION_ID,
    IN_START_DATE => IN_START_DATE,
    IN_SUSPEND_PERIOD => IN_SUSPEND_PERIOD
  );
--rollback; 
END;
/



