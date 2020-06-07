-- script to test PROC_SUSPEND_ALL_COURSE
DECLARE
  IN_STUDENT_ID NUMBER;
  IN_START_DAT DATE;
  IN_PERIOD NUMBER;
BEGIN
  IN_STUDENT_ID := 401;
  IN_START_DAT := sysdate;
  IN_PERIOD := 1;

  PROC_SUSPEND_ALL_COURSE(
    IN_STUDENT_ID => IN_STUDENT_ID,
    IN_START_DAT => IN_START_DAT,
    IN_PERIOD => IN_PERIOD
  );
--rollback; 
END;
/
--test case 1
INSERT INTO student VALUES (401,'Mr.','Test','Test','101-09 120th St.','11419','718-555-5555','Albert Hildegard Co.','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO enrollment VALUES (401,86,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO enrollment VALUES (401,87,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO grade VALUES (401,86,'FI',1,85,NULL,'CBRENNAN',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'JAYCAF',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));
INSERT INTO grade VALUES (401,87,'FI',1,85,NULL,'CBRENNAN',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'JAYCAF',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));

COMMIT;
select * from student where student_id = 401;
select * from enrollment where student_id = 401;
select * from grade where student_id = 401;

select * from student_log where student_id = 401;
select * from enrollment_log where student_id = 400;
select *  from STUDENT_COURSE_SUSPENSION;


--test case 2
select * from student where student_id = 102;
select * from enrollment where student_id = 102;
select * from grade where student_id = 102;

select * from student_log where student_id = 400;
select * from enrollment_log where student_id = 400;

