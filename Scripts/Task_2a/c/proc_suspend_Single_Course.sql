--Assumsions
-- In GRADE table, for same student_id,section_id and grade_type_code combination, GRADE_CODE_OCCURRENCE column update sequentially(one by one).
-- student must complete all the number of assignments to complete the course, irrespective of drop lowest allowed for purticular subject assignenment
-- login database user considered as created user
-- Relevent grade table data is deleted to maintain data integrity, as student not enrolled to section/course will invalidate the relevent grade data

-- Checks
-- need to be valid student
-- should be enrolled on that course
-- taken any assesment

-- 
-- can do for given period ( one/two academic year)
--      => once for two consecutive years
--      => or suspend twice (one year each)
-- can suspend one or all courses => if still have more assessments to complete



/*--- Helper function to proc_suspend_Single_Course procedure

This function will check the given student_id has completed the all assignement related to given section
Return True if Yes, False if No
*/
CREATE OR REPLACE FUNCTION func_check_Course_Completion( in_student_id IN NUMBER, 
                                                                    in_section_id IN NUMBER
                                                                )
RETURN BOOLEAN
IS
    num_assess_check NUMBER;

    cursor c1 is
        SELECT grade_type_code, number_per_section
        FROM grade_type_weight
        WHERE section_id = in_section_id;

BEGIN
    
    FOR grade_type_weight_rec in c1
    LOOP
        SELECT NVL(max(grade_code_occurrence),0) INTO num_assess_check
        FROM grade
        WHERE student_id = in_student_id
          AND section_id = in_section_id
          AND grade_type_code = grade_type_weight_rec.grade_type_code;
          
        IF num_assess_check != grade_type_weight_rec.number_per_section THEN
            RETURN FALSE;
        END IF;
        
    END LOOP;
    
    RETURN TRUE;
    
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
    
END;
/




CREATE OR REPLACE PROCEDURE proc_suspend_Single_Course( in_student_id IN NUMBER, 
                                             in_section_id IN NUMBER,
                                             in_start_date IN DATE,
                                             in_suspend_period IN NUMBER
                                           )
IS
    C_SUS_MAX_ALLOWED_YEARS NUMBER := 2;
    v_action VARCHAR2(30) :='COURSE_SUSPEND';
    
    num_student_check NUMBER;
    num_enrollment_check NUMBER;
    num_assessment_check NUMBER;
    num_student_enroll_check NUMBER;
    bool_assignment_check BOOLEAN;
    num_suspended_year_sum NUMBER;
    num_stud_eligible_sus_period NUMBER;  
    transaction_dtm DATE;

    v_rec enrollment%ROWTYPE;
    v_rec_student student%ROWTYPE;

BEGIN
    IF in_student_id is NULL OR in_section_id IS NULL OR in_start_date IS NULL OR in_suspend_period IS NULL THEN
        raise_application_error(-20100, 'Invalid input parameters');
    END IF;
    
    IF in_suspend_period > C_SUS_MAX_ALLOWED_YEARS OR in_suspend_period <=0 THEN
        raise_application_error(-20105, 'Given suspension period is not allowed');
    END IF;

    SELECT count(*) INTO num_student_check
    FROM student
    WHERE student_id = in_student_id;

    -- validating student is available
    IF num_student_check = 0 THEN 
        raise_application_error(-20101, 'Student is not available');
    END IF;
    
    -- validating student has enrolled to the given section/class
    SELECT count(*) INTO num_enrollment_check
    FROM enrollment
    WHERE student_id = in_student_id
        AND section_id = in_section_id;
    
    IF num_enrollment_check = 0 THEN 
        raise_application_error(-20102, 'Student:'|| in_student_id ||' has not enrolled to section/class:'||in_section_id);
    END IF;
    
    -- checking student has attended any assignment related to changing class
    SELECT count(*) INTO num_assessment_check
    FROM grade
    WHERE student_id = in_student_id
        AND section_id = in_section_id;

    IF num_assessment_check = 0 THEN
        raise_application_error(-20106, 'Course Suspension is Not Allowed, as student have not taken any assessment');
    END IF;
    
    -- check for pending assignments
    bool_assignment_check := func_check_Course_Completion(   in_student_id => in_student_id,
                                                             in_section_id => in_section_id
                                            );
    
    IF bool_assignment_check = TRUE  THEN
        raise_application_error(-20107, 'No pending assignements, suspension not allowed');
    END IF;
    
    --check suspension year count exceeds allowed number of years
    SELECT NVL(SUM(suspension_period_in_years),0) INTO num_suspended_year_sum
    FROM STUDENT_COURSE_SUSPENSION
    WHERE student_id = in_student_id
      AND section_id = in_section_id;
      
    num_stud_eligible_sus_period := C_SUS_MAX_ALLOWED_YEARS - num_suspended_year_sum;
    
    IF num_stud_eligible_sus_period < in_suspend_period THEN
        raise_application_error(-20108, 'Student not allowed for '||in_suspend_period||' year suspension period. Student eligible only for '||num_stud_eligible_sus_period ||' suspension years.');
    END IF;
    
    transaction_dtm := sysdate;
      
    --Delete Grade table records
    DELETE FROM grade
    WHERE student_id = in_student_id
      AND section_id = in_section_id;
      
    --getting deleting record from enrollment table to log
    SELECT * INTO v_rec
    FROM enrollment
    WHERE student_id = in_student_id
    AND section_id = in_section_id;
      
    --Delete Enrollment record
    DELETE FROM enrollment
    WHERE student_id = in_student_id
    AND section_id = in_section_id;
    
    -- Insert Into enrollment log table 
    INSERT INTO ENROLLMENT_LOG
     ( TRANSACTION_DTM ,TRANSACTION_OWNER ,ACTION_PERFORMED, STUDENT_ID, OLD_SECTION_ID, OLD_ENROLL_DATE , OLD_FINAL_GRADE
        , OLD_CREATED_BY ,OLD_CREATED_DATE ,OLD_MODIFIED_BY ,OLD_MODIFIED_DATE ,NEW_SECTION_ID )
    VALUES
    (transaction_dtm, USER, v_action, in_student_id, v_rec.SECTION_ID, v_rec.ENROLL_DATE , v_rec.FINAL_GRADE
        , v_rec.CREATED_BY ,v_rec.CREATED_DATE ,v_rec.MODIFIED_BY ,v_rec.MODIFIED_DATE ,NULL  );
    
   -- delete student record if only enroll to one course
    SELECT count(*) INTO num_student_enroll_check
    FROM enrollment
    WHERE student_id = in_student_id;
    
    IF num_student_enroll_check = 0 THEN 
        --getting deleting record from student table to log
        SELECT * INTO v_rec_student
        FROM student
        WHERE student_id = in_student_id;
        
        DELETE FROM student 
            WHERE student_id = in_student_id;
            
        --logging to student log table
         INSERT INTO STUDENT_LOG
         (TRANSACTION_DTM  ,TRANSACTION_OWNER  ,ACTION_PERFORMED  ,STUDENT_ID  ,OLD_SALUTATION  ,OLD_FIRST_NAME  ,OLD_LAST_NAME  ,OLD_STREET_ADDRESS  ,OLD_ZIP  ,OLD_PHONE  ,OLD_EMPLOYER  ,OLD_REGISTRATION_DATE  
            ,OLD_CREATED_BY  ,OLD_CREATED_DATE  ,OLD_MODIFIED_BY  ,OLD_MODIFIED_DATE)
         VALUES
         (transaction_dtm, USER, v_action, in_student_id , v_rec_student.SALUTATION  ,v_rec_student.FIRST_NAME  ,v_rec_student.LAST_NAME  ,v_rec_student.STREET_ADDRESS  ,v_rec_student.ZIP  ,v_rec_student.PHONE  ,v_rec_student.EMPLOYER  ,v_rec_student.REGISTRATION_DATE  ,v_rec_student.CREATED_BY  
            ,v_rec_student.CREATED_DATE  ,v_rec_student.MODIFIED_BY  ,v_rec_student.MODIFIED_DATE);
            
    END IF; 
    
    --insert record into STUDENT_COURSE_SUSPENSION table
    INSERT INTO STUDENT_COURSE_SUSPENSION VALUES (in_student_id,in_section_id,in_suspend_period,
        in_start_date, add_months(in_start_date,12), USER, transaction_dtm ); 

    --
    -- Insert Into log table, Student and Enrolment
    --
    --
    COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
    
END;
/
