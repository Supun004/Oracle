--WITHDRAW_COURSE
-- Testing student only enrolled to one course

select * from student where  student_id =400;
select * from enrollment where  student_id =400;
select * from student_log where  student_id =400;
select * from enrollment_log where  student_id =400;

-- Testing student only enrolled to one course
INSERT INTO student VALUES (400,'Mr.','Test','Crocitto','101-09 120th St.','11419','718-555-5555','Albert Hildegard Co.','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 

INSERT INTO enrollment VALUES (400,91,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
COMMIT;



DECLARE
  IN_STUDENT_ID NUMBER;
  IN_SECTION_ID NUMBER;
BEGIN
  IN_STUDENT_ID := 400;
  IN_SECTION_ID := 91;

  proc_withdraw_Course(
    IN_STUDENT_ID => IN_STUDENT_ID,
    IN_SECTION_ID => IN_SECTION_ID
  );
--rollback; 
END;
/
select * from student where  student_id =400;
select * from enrollment where  student_id =400;
select * from student_log where  student_id =400;
select * from enrollment_log where  student_id =400;


