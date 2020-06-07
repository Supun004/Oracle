--Assumtpion
--insert update and delete from table is not allowed during off work ours
-- off work hours Friday 5.00 pm to Monday 8:00 am
CREATE OR REPLACE TRIGGER tr_secure_grade BEFORE
INSERT OR UPDATE OR DELETE ON grade
BEGIN
    IF (TO_CHAR(SYSDATE,'DY') IN ('SAT','SUN')) OR 
            ( TO_CHAR(SYSDATE,'DY') = 'MON' AND (TO_CHAR(SYSDATE,'HH24:MI') BETWEEN '00:00' AND '08:00')) OR
             ( TO_CHAR(SYSDATE,'DY') = 'FRI' AND (TO_CHAR(SYSDATE,'HH24:MI') BETWEEN '17:00' AND '23:59')) THEN
        
        IF DELETING THEN RAISE_APPLICATION_ERROR(-20501,'You may delete from grade table '||
                                                            'only during normal working hours.');
                                                            
        ELSIF INSERTING THEN RAISE_APPLICATION_ERROR(-20502,'You may insert into grade table '||
                                                            'only during normal working hours.');
                                                            
        ELSIF UPDATING THEN RAISE_APPLICATION_ERROR(-20503, 'You may '||'update grade table only during normal working hours.');
        
        END IF;
        
    END IF;
END;
/


ALTER SYSTEM SET fixed_date='2020-05-08-17:00:00';
INSERT INTO grade VALUES (102,86,'FI',1,85,NULL,'CBRENNAN',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'JAYCAF',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));
INSERT INTO grade VALUES (102,86,'HM',1,90,NULL,'CBRENNAN',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'JAYCAF',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));
INSERT INTO grade VALUES (102,86,'HM',2,99,NULL,'CBRENNAN',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'JAYCAF',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));
INSERT INTO grade VALUES (102,86,'HM',3,82,NULL,'CBRENNAN',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'JAYCAF',TO_DATE('11-FEB-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));

ALTER SYSTEM SET fixed_date=NONE;
