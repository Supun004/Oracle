BEGIN
  PROC_GENERATE_REPORTS();
--rollback; 
END;
/
select * from course_stats;
select * from student_final_mark;