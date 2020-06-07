alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

select * from enrollment where student_id =102 and section_id = 90;
select * from enrollment_log;

--course_change test students enrolled without attending enrollment
INSERT INTO enrollment VALUES (102,90,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
commit;

select * from enrollment where student_id =102 and section_id = 90;
select * from enrollment_log;

-- Script to test proc_change_Course
DECLARE
  IN_STUDENT_ID NUMBER;
  IN_OLD_SECTION_ID NUMBER;
  IN_NEW_SECTION_ID NUMBER;
BEGIN
  IN_STUDENT_ID := 102;
  IN_OLD_SECTION_ID := 90;
  IN_NEW_SECTION_ID := 91;

  proc_change_Course(
    IN_STUDENT_ID => IN_STUDENT_ID,
    IN_OLD_SECTION_ID => IN_OLD_SECTION_ID,
    IN_NEW_SECTION_ID => IN_NEW_SECTION_ID
  );
--rollback; 
END;
/

select * from enrollment where student_id =102 and section_id = 90;
select * from grade where student_id =102 and section_id = 90;
