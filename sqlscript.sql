SET serveroutput ON;
    --regisid--
CREATE OR REPLACE  PROCEDURE ANALYZE_TEST(p_registrationno registration.registrationno%TYPE) IS
    v_correct_count NUMBER := 0;
    v_maxscore NUMBER := 0;
    v_regisnum NUMBER := p_registrationno;
    v_ans NUMBER := 0;
    v_test NUMBER := 0;
    CURSOR regisid_cur (p_registrationno_cur registration.registrationno%TYPE) IS
        SELECT *
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
        WHERE qt.registrationno = p_registrationno;
    regisid_rec regisid_cur%ROWTYPE;
    BEGIN
        OPEN regisid_cur(p_registrationno);
        DBMS_OUTPUT.PUT_LINE('Registation ID: ' || v_regisnum);
        DBMS_OUTPUT.PUT_LINE('');
        LOOP
        FETCH regisid_cur INTO regisid_rec;
        EXIT WHEN regisid_cur%NOTFOUND;
        ----Analysis answer----
        IF regisid_rec.answer = 'A' THEN
            v_ans := regisid_rec.a_id;
            CASE
                WHEN regisid_rec.testanswer = 'A' THEN
                    v_test := regisid_rec.a_id;
                WHEN regisid_rec.testanswer = 'B' THEN
                    v_test := regisid_rec.b_id;
                WHEN regisid_rec.testanswer = 'C' THEN
                    v_test := regisid_rec.c_id;
                ELSE
                    v_test := regisid_rec.c_id;
            END CASE;
        ELSIF regisid_rec.answer = 'B' THEN
            v_ans := regisid_rec.b_id;
            CASE
                WHEN regisid_rec.testanswer = 'A' THEN
                    v_test := regisid_rec.a_id;
                WHEN regisid_rec.testanswer = 'B' THEN
                    v_test := regisid_rec.b_id;
                WHEN regisid_rec.testanswer = 'C' THEN
                    v_test := regisid_rec.c_id;
                ELSE
                    v_test := regisid_rec.c_id;
            END CASE;
        ELSIF regisid_rec.answer = 'C' THEN
            v_ans := regisid_rec.c_id;
            CASE
                WHEN regisid_rec.testanswer = 'A' THEN
                    v_test := regisid_rec.a_id;
                WHEN regisid_rec.testanswer = 'B' THEN
                    v_test := regisid_rec.b_id;
                WHEN regisid_rec.testanswer = 'C' THEN
                    v_test := regisid_rec.c_id;
                ELSE
                    v_test := regisid_rec.c_id;
            END CASE;
        ELSE
            v_ans := regisid_rec.d_id;
            CASE
                WHEN regisid_rec.testanswer = 'A' THEN
                    v_test := regisid_rec.a_id;
                WHEN regisid_rec.testanswer = 'B' THEN
                    v_test := regisid_rec.b_id;
                WHEN regisid_rec.testanswer = 'C' THEN
                    v_test := regisid_rec.c_id;
                ELSE
                    v_test := regisid_rec.c_id;
            END CASE;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Question: ' || regisid_rec.question);
        DBMS_OUTPUT.PUT_LINE('Subject Code: ' || regisid_rec.subjectcode || ' Chapter: ' || regisid_rec.chapter 
                             || ' Correct answer ID: ' || v_ans || ' User answer ID: ' || v_test);
        ----Count score----
        IF regisid_rec.answer = regisid_rec.testanswer THEN 
            v_correct_count := v_correct_count + 1;
            DBMS_OUTPUT.PUT_LINE('True!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('False!');
        END IF;
        v_maxscore := v_maxscore + 1;
        DBMS_OUTPUT.PUT_LINE('');
        END LOOP;
    
        CLOSE regisid_cur;
        DBMS_OUTPUT.PUT_LINE('Score of ' || regisid_rec.registrationno || ' is ' || v_correct_count || ' / ' ||  v_maxscore);
    END ANALYZE_TEST;

EXECUTE ANALYZE_TEST(300001);