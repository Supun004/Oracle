--Assumtpion
--insert update and delete from table is not allowed during off work ours
-- off work hours Friday 5.00 pm to Monday 8:00 am
CREATE OR REPLACE TRIGGER tr_secure_student BEFORE
INSERT OR UPDATE OR DELETE ON student
BEGIN
    IF (TO_CHAR(SYSDATE,'DY') IN ('SAT','SUN')) OR 
            ( TO_CHAR(SYSDATE,'DY') = 'MON' AND (TO_CHAR(SYSDATE,'HH24:MI') BETWEEN '00:00' AND '08:00')) OR
             ( TO_CHAR(SYSDATE,'DY') = 'FRI' AND (TO_CHAR(SYSDATE,'HH24:MI') BETWEEN '17:00' AND '23:59')) THEN
        
        IF DELETING THEN RAISE_APPLICATION_ERROR(-20501,'You may delete from STUDENT table '||
                                                            'only during normal working hours.');
                                                            
        ELSIF INSERTING THEN RAISE_APPLICATION_ERROR(-20502,'You may insert into STUDENT table '||
                                                            'only during normal working hours.');
                                                            
        ELSIF UPDATING THEN RAISE_APPLICATION_ERROR(-20503, 'You may '||'update STUDENT table only during normal working hours.');
        
        END IF;
        
    END IF;
END;
/

ALTER SYSTEM SET fixed_date='2020-05-08-17:00:00';
select sysdate from dual;
INSERT INTO student VALUES (403,'Mr.','Fred','Crocitto','101-09 120th St.','11419','718-555-5555','Albert Hildegard Co.','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS')); 
INSERT INTO student VALUES (103,'Ms.','J.','Landry','7435 Boulevard East #45','07047','201-555-5555','Albert Hildegard Co.','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));   
INSERT INTO student VALUES (104,'Ms.','Laetia','Enison','144-61 87th Ave','11435','718-555-5555','Albert Hildegard Co.','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));  
INSERT INTO student VALUES (105,'Mr.','Angel','Moskowitz','320 John St.','07024','201-555-5555','Alex. & Alexander','22-JAN-07','BROSENZWEIG',TO_DATE('19-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'),'BROSENZW',TO_DATE('22-JAN-2007 00:00:00','DD-MON-YYYY HH24:MI:SS'));

ALTER SYSTEM SET fixed_date=NONE;