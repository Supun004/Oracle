--This is a helper function to generate final mark of student for specific course
-- output - INTEGER - final grade mark for specific course will be return, if the given
            --student succssfully completed all the assignements, otherwise NULL will be returned
--Assumtions
--If drop_lowest is allowed then, lowest mark for that grade type will be neglected, if he completed all the number of assignment
CREATE OR REPLACE FUNCTION func_student_final_course_mark( in_student_id IN NUMBER,
                                                              in_section_id IN NUMBER )
RETURN NUMBER
IS
 num_assess_check NUMBER;
 bool_assess_completed BOOLEAN := FALSE;
 bool_special_case BOOLEAN := FALSE;
 num_tot_mark NUMBER :=0;
 
 num_temp_sum NUMBER;
 num_temp_min NUMBER;
 
 num_grad_type_mark NUMBER;
 counter NUMBER;

    cursor c1 is
        SELECT grade_type_code, number_per_section, drop_lowest, percent_of_final_grade
        FROM grade_type_weight
        WHERE section_id = in_section_id;
BEGIN
    BEGIN
    
        counter :=0;
        
        
        FOR grade_type_weight_rec in c1
        LOOP
            num_temp_sum :=0;
            num_temp_min :=0;
            
            counter := counter+1;
     
            num_grad_type_mark :=0;
    
            SELECT NVL(MAX(grade_code_occurrence),0) INTO num_assess_check
            FROM grade
            WHERE student_id = in_student_id
              AND section_id = in_section_id
              AND grade_type_code = grade_type_weight_rec.grade_type_code;
            
            IF num_assess_check = grade_type_weight_rec.number_per_section THEN
                bool_assess_completed := TRUE;    
                IF grade_type_weight_rec.drop_lowest = 'Y' THEN
                    SELECT SUM(NUMERIC_GRADE) INTO num_temp_sum
                    FROM grade
                    WHERE student_id = in_student_id
                      AND section_id = in_section_id
                      AND grade_type_code = grade_type_weight_rec.grade_type_code;
                
                    SELECT MIN(NUMERIC_GRADE) INTO num_temp_min
                    FROM grade
                    WHERE student_id = in_student_id
                      AND section_id = in_section_id
                      AND grade_type_code = grade_type_weight_rec.grade_type_code;
                    
                    num_temp_sum := num_temp_sum - num_temp_min;
                    
                    num_grad_type_mark := num_temp_sum/(grade_type_weight_rec.number_per_section - 1);
                 
                 ELSE
                    SELECT AVG(NUMERIC_GRADE) INTO num_grad_type_mark
                    FROM grade
                    WHERE student_id = in_student_id
                      AND section_id = in_section_id
                      AND grade_type_code = grade_type_weight_rec.grade_type_code;
                    
                 END IF;
                
                    
                
            ELSE 
                IF num_assess_check = (grade_type_weight_rec.number_per_section -1)
                    AND grade_type_weight_rec.drop_lowest = 'Y' THEN
                      bool_assess_completed := TRUE;
                      
                     SELECT AVG(NUMERIC_GRADE) INTO num_grad_type_mark
                     FROM grade
                     WHERE student_id = in_student_id
                        AND section_id = in_section_id
                        AND grade_type_code = grade_type_weight_rec.grade_type_code;
                      
                END IF; 
            END IF;
            
            IF bool_assess_completed THEN
                num_tot_mark := num_tot_mark + num_grad_type_mark * grade_type_weight_rec.percent_of_final_grade;            
            
            ELSE
                num_tot_mark := NULL;
                RETURN num_tot_mark;
                --raise_application_error(-20108, 'Student has not completed all the assignements');
            END IF;
            
            
        END LOOP;
        
        -- update final grade of student in enrollment table
        
    --    UPDATE enrollment
    --    SET final_grade = num_tot_mark/100,
    --    MODIFIED_BY = USER,
    --    MODIFIED_DATE = SYSDATE
    --    WHERE student_id = in_student_id
    --      AND section_id = in_section_id;
    --    COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                num_tot_mark :=NULL;
                --raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
              
    END;
return ROUND(num_tot_mark/100);  
END;
/


--procedure to generate final marks of students for each course
-- report will be output to student_final_mark table
-- helper procedure to proc_generate_reports
CREATE OR REPLACE PROCEDURE proc_generate_final_marks
IS
    num_student_check NUMBER;
    num_enrollment_check NUMBER;
    num_assessment_check NUMBER;
    v_action VARCHAR2(30) :='COURSE_CHANGE';
    transaction_dtm DATE;

    v_rec enrollment%ROWTYPE;
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE student_final_mark';
    INSERT INTO student_final_mark
    SELECT s.student_id,s.salutation,s.first_name, s.last_name, s.phone,e.section_id,
        st.start_date_time, st.instructor_id, st.course_no, c.description,
        func_student_final_course_mark(s.student_id,e.section_id) final_marks
        FROM student s
        INNER JOIN enrollment e
        ON s.student_id = e.student_id
        INNER JOIN section st
        ON e.section_id = st.section_id
        INNER JOIN course c
        ON st.course_no = c.course_no
        ORDER BY STUDENT_ID;
    
    COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
   
    
END;
/


-- This procedure will generate two reports, into mentioned tables
-- 1. final marks of students for each course => student_final_mark
-- 2. coursewise statistical report => course_stats
CREATE OR REPLACE PROCEDURE proc_generate_reports
IS
max_marks NUMBER;
min_marks NUMBER;
avg_marks NUMBER;
std_marks NUMBER;
num_1st_count NUMBER;
num_2nd_count NUMBER;
num_3rd_count NUMBER;
num_failure_count NUMBER;
num_of_students NUMBER;

BEGIN
    PROC_GENERATE_FINAL_MARKS();
    
    EXECUTE IMMEDIATE 'TRUNCATE TABLE course_stats';
    
    FOR section_rec IN ( SELECT s.COURSE_NO, c.DESCRIPTION, s.section_id, s.START_DATE_TIME,
                                ins.salutation, ins.first_name , ins.last_name
                            FROM section s, course c, instructor ins 
                            WHERE s.course_no = c.course_no
                            AND s.INSTRUCTOR_ID = ins.INSTRUCTOR_ID )
    LOOP
        SELECT COUNT(*) INTO num_of_students
        FROM student_final_mark
        WHERE section_id = section_rec.section_id;
        
        SELECT MAX(final_marks), MIN(final_marks),ROUND(AVG(final_marks),2), ROUND(STDDEV(final_marks),2)
            INTO max_marks, min_marks, avg_marks, std_marks
        FROM student_final_mark
        WHERE section_id = section_rec.section_id;
        
        SELECT COUNT(*) INTO num_1st_count
        FROM student_final_mark
        WHERE section_id = section_rec.section_id
          AND final_marks>=80;
          
        SELECT COUNT(*) INTO num_2nd_count
        FROM student_final_mark
        WHERE section_id = section_rec.section_id
          AND final_marks<80 AND final_marks>=70;
          
        SELECT COUNT(*) INTO num_3rd_count
        FROM student_final_mark
        WHERE section_id = section_rec.section_id
          AND final_marks<70 AND final_marks>=60;
    
        SELECT COUNT(*) INTO num_failure_count
        FROM student_final_mark
        WHERE section_id = section_rec.section_id
          AND final_marks<60;
        
        INSERT INTO  course_stats
         VALUES (section_rec.COURSE_NO, section_rec.DESCRIPTION, section_rec.section_id, section_rec.START_DATE_TIME,
                    section_rec.salutation, section_rec.first_name , section_rec.last_name ,
                        num_of_students, max_marks, min_marks, avg_marks, std_marks,num_1st_count, num_2nd_count, num_3rd_count, num_failure_count
                );
          
    END LOOP;
    
    COMMIT;
EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);

END;


