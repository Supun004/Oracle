  
-- Checks
-- need to be valid student
-- should be enrolled on that course
-- allowed if begining of section, before undergo any assesment

-- withdraw course tasks
-- delete Enrolment table record
-- if student not enrolled to any other courses => delete stuent
-- Enrolment/student log table =>  message to indicate the change

CREATE OR REPLACE PROCEDURE proc_withdraw_Course( in_student_id IN NUMBER, 
                                                  in_section_id IN NUMBER
                                                )
IS
    num_student_check NUMBER;
    num_enrollment_check NUMBER;
    num_assessment_check NUMBER;
    num_student_enroll_check NUMBER;
    v_action VARCHAR2(30) :='COURSE_WITHDRAW';
    transaction_dtm DATE;
    
    v_rec enrollment%ROWTYPE;
    v_rec_student student%ROWTYPE;

BEGIN
    IF in_student_id is NULL OR in_section_id IS NULL  THEN
        raise_application_error(-20100, 'Invalid input parameters');
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

    IF num_assessment_check <> 0 THEN
        raise_application_error(-20104, 'Course Withdrawal is Not Allowed, as student already undergone some assessment/s');
    END IF;
    
    --getting deleting record from enrollment table to log
    SELECT * INTO v_rec
    FROM enrollment
    WHERE student_id = in_student_id
    AND section_id = in_section_id;
    
    transaction_dtm := sysdate;
    
    -- deleting enrollment table record
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
    
    
        
COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);

    
END;
/
