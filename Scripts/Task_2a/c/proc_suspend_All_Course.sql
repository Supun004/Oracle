-- This procedure will suspend all the eligible course one time
CREATE OR REPLACE PROCEDURE proc_suspend_All_Course( in_student_id IN NUMBER,
                                                     in_start_dat IN DATE,
                                                     in_period IN NUMBER)
IS
    num_assess_check NUMBER;

    cursor c1 is
        SELECT section_id
        FROM enrollment
        WHERE student_id = in_student_id;

BEGIN
    
    FOR rec in c1
    LOOP
        BEGIN
        PROC_SUSPEND_SINGLE_COURSE(
            IN_STUDENT_ID => in_student_id,
            IN_SECTION_ID => rec.section_id,
            IN_START_DATE => in_start_dat,
            IN_SUSPEND_PERIOD => in_period
          );
          
        EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
        END;
    END LOOP;
    
    
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
    
END;
/