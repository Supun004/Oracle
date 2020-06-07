
-- Checks
-- need to be valid student
-- should be enrolled on that course
-- allowed if begining of section, before undergo any assesment

-- Course Change tasks
-- update Enrolment table => new_section details
-- create Enrolment log table => old section/ new section/ message to indicate the change
CREATE OR REPLACE PROCEDURE proc_change_Course( in_student_id IN NUMBER, 
                                           in_old_section_id IN NUMBER, 
                                           in_new_section_id IN NUMBER
                                         )
IS
    num_student_check NUMBER;
    num_enrollment_check NUMBER;
    num_assessment_check NUMBER;
    v_action VARCHAR2(30) :='COURSE_CHANGE';
    transaction_dtm DATE;

    v_rec enrollment%ROWTYPE;
BEGIN
    IF in_student_id is NULL OR in_old_section_id IS NULL OR in_new_section_id IS NULL THEN
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
        AND section_id = in_old_section_id;
    
    IF num_enrollment_check = 0 THEN 
        raise_application_error(-20102, 'Student:'|| in_student_id ||' has not enrolled to section/class:'||in_old_section_id);
    END IF;
    
    -- checking student has attended any assignment related to changing class
    SELECT count(*) INTO num_assessment_check
    FROM grade
    WHERE student_id = in_student_id
        AND section_id = in_old_section_id;

    IF num_assessment_check <> 0 THEN
        raise_application_error(-20103, 'Course Change is Not Allowed, as student already undergone some assessment/s');
    END IF;
    
    --getting values of updating record of enrollment table
    SELECT * INTO v_rec
    FROM enrollment
    WHERE student_id = in_student_id
    AND section_id = in_old_section_id;
    
    transaction_dtm := SYSDATE;
--     Updating enrollment table
    UPDATE enrollment
    SET SECTION_ID  = in_new_section_id,
        MODIFIED_BY = USER,
        MODIFIED_DATE = transaction_dtm
    WHERE student_id = in_student_id
    AND section_id = in_old_section_id;

    -- Insert Into log table
    INSERT INTO ENROLLMENT_LOG
     ( TRANSACTION_DTM ,TRANSACTION_OWNER ,ACTION_PERFORMED, STUDENT_ID, OLD_SECTION_ID, OLD_ENROLL_DATE , OLD_FINAL_GRADE
        , OLD_CREATED_BY ,OLD_CREATED_DATE ,OLD_MODIFIED_BY ,OLD_MODIFIED_DATE ,NEW_SECTION_ID )
    VALUES
    (transaction_dtm, USER, v_action, in_student_id, v_rec.SECTION_ID, v_rec.ENROLL_DATE , v_rec.FINAL_GRADE
        , v_rec.CREATED_BY ,v_rec.CREATED_DATE ,v_rec.MODIFIED_BY ,v_rec.MODIFIED_DATE ,in_new_section_id  );
    
    COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);

    
    
END;
/
