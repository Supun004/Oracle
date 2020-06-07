--Assumtpion
--insert update and delete from table is not allowed during off work ours
-- off work hours Friday 5.00 pm to Monday 8:00 am
CREATE OR REPLACE TRIGGER tr_secure_enrollment BEFORE
INSERT OR UPDATE OR DELETE ON enrollment
BEGIN
    IF (TO_CHAR(SYSDATE,'DY') IN ('SAT','SUN')) OR 
            ( TO_CHAR(SYSDATE,'DY') = 'MON' AND (TO_CHAR(SYSDATE,'HH24:MI') BETWEEN '00:00' AND '08:00')) OR
             ( TO_CHAR(SYSDATE,'DY') = 'FRI' AND (TO_CHAR(SYSDATE,'HH24:MI') BETWEEN '17:00' AND '23:59')) THEN
        
        IF DELETING THEN RAISE_APPLICATION_ERROR(-20501,'You may delete from enrollment table '||
                                                            'only during normal working hours.');
                                                            
        ELSIF INSERTING THEN RAISE_APPLICATION_ERROR(-20502,'You may insert into enrollment table '||
                                                            'only during normal working hours.');
                                                            
        ELSIF UPDATING THEN RAISE_APPLICATION_ERROR(-20503, 'You may '||'update enrollment table only during normal working hours.');
        
        END IF;
        
    END IF;
END;
/


ALTER SYSTEM SET fixed_date='2020-05-08-17:00:00';
INSERT INTO enrollment VALUES (102,85,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO enrollment VALUES (102,89,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),92,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));   
INSERT INTO enrollment VALUES (103,81,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO enrollment VALUES (104,81,TO_DATE('30-JAN-2007 10:18:00','DD-MON-YYYY HH24:MI:SS'),NULL,'JAYCAF',TO_DATE('03-NOV-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'CBRENNAN',TO_DATE('12-DEC-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
ALTER SYSTEM SET fixed_date=NONE;
