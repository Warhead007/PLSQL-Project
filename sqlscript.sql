SET serveroutput ON;
    --regisid--
    CREATE OR REPLACE  PROCEDURE ANALYZE_TEST(p_registrationno registration.registrationno%TYPE) IS
        v_correct_count NUMBER := 0;
        v_maxscore NUMBER := 0;
        CURSOR regisid_cur (p_registrationno_cur registration.registrationno%TYPE) IS
            SELECT qt.registrationno,qb.question,qb.subjectcode,qb.chapter,qt.answer,qt.testanswer
            FROM questiontest qt
            JOIN questionbank qb on qt.questionid = qb.questionid
            WHERE qt.registrationno = p_registrationno;
        regisid_rec regisid_cur%ROWTYPE;
    BEGIN
        OPEN regisid_cur(p_registrationno);
        LOOP
        FETCH regisid_cur INTO regisid_rec;
        EXIT WHEN regisid_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('registation ID: ' || regisid_rec.registrationno || ' Question: ' || regisid_rec.question
        || ' Subject Code: ' || regisid_rec.subjectcode || ' Chapter: ' || regisid_rec.chapter 
        ||  ' Correct answer: ' || regisid_rec.answer || ' User answer: ' || regisid_rec.testanswer);
        IF regisid_rec.answer = regisid_rec.testanswer THEN 
            v_correct_count := v_correct_count + 1;
            DBMS_OUTPUT.PUT_LINE('True!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('False!');
        END IF;
        v_maxscore := v_maxscore + 1;
        END LOOP;
        CLOSE regisid_cur;
        DBMS_OUTPUT.PUT_LINE('Score of ' || regisid_rec.registrationno || ' is ' || v_correct_count || ' / ' ||  v_maxscore);
    END ANALYZE_TEST;

EXECUTE ANALYZE_TEST(300001);