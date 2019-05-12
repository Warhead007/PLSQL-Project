SET serveroutput ON;


CREATE OR REPLACE  PROCEDURE ANALYZE_TEST(p_registrationno registration.registrationno%TYPE) IS
    v_question_id NUMBER := 0;
    v_correct_count NUMBER := 0;
    v_maxscore NUMBER := 0;
    v_regisnum NUMBER := p_registrationno;
    v_ans NUMBER := 0;
    v_test NUMBER := 0;
    CURSOR regisid_cur (p_registrationno_cur registration.registrationno%TYPE) IS
        SELECT r.subjectcode,r.testdate,qt.a_id,qt.b_id,qt.c_id,qt.d_id,qt.answer,
        qt.testanswer,qb.chapter,qt.questionid,qb.question,qt.registrationno
        FROM questiontest qt
        JOIN questionbank qb ON qt.questionid = qb.questionid
        JOIN registration r ON r.registrationno = qt.registrationno
        WHERE qt.registrationno = p_registrationno;
    regisid_rec regisid_cur%ROWTYPE;
    
    v_true_count NUMBER := 0;
    v_false_count NUMBER := 0;
    v_regis_id NUMBER := 0;
    v_a_id NUMBER := 0;
    v_b_id NUMBER := 0;
    v_c_id NUMBER := 0;
    v_d_id NUMBER := 0;
    v_a_count NUMBER := 0;
    v_b_count NUMBER := 0;
    v_c_count NUMBER := 0;
    v_d_count NUMBER := 0;
    CURSOR other_regis_cur IS
        SELECT r.subjectcode,r.testdate,qt.a_id,qt.b_id,qt.c_id,qt.d_id,qt.answer,qt.testanswer,qt.questionid
        FROM registration r
        JOIN questiontest qt ON r.registrationno = qt.registrationno;
    --other_regis_rec other_regis_cur%ROWTYPE;
    
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
                        v_test := regisid_rec.d_id;
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
                        v_test := regisid_rec.d_id;
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
                        v_test := regisid_rec.d_id;
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
                        v_test := regisid_rec.d_id;
                END CASE;
            END IF;
            
            v_question_id := regisid_rec.questionid;
            v_true_count := 0;
            v_false_count := 0;
            v_a_count := 0;
            v_b_count := 0;
            v_c_count := 0;
            v_d_count := 0;
            
            FOR other_regis_rec IN other_regis_cur LOOP
                IF regisid_rec.subjectcode = other_regis_rec.subjectcode
                AND regisid_rec.testdate = other_regis_rec.testdate
                AND v_question_id = other_regis_rec.questionid THEN
                CASE
                    WHEN other_regis_rec.testanswer = 'A' THEN
                        v_regis_id := other_regis_rec.a_id;
                        v_a_id := other_regis_rec.a_id;
                        v_a_count := v_a_count + 1;
                    WHEN other_regis_rec.testanswer = 'B' THEN
                        v_regis_id := other_regis_rec.b_id;
                        v_b_id := other_regis_rec.a_id;
                        v_b_count := v_b_count + 1;
                    WHEN other_regis_rec.testanswer = 'C' THEN
                        v_regis_id := other_regis_rec.c_id;
                        v_c_id := other_regis_rec.a_id;
                        v_c_count := v_c_count + 1;
                    ELSE
                        v_regis_id := other_regis_rec.d_id;
                        v_d_id := other_regis_rec.a_id;
                        v_d_count := v_d_count + 1;
                END CASE;
                IF v_regis_id = v_ans THEN
                    v_true_count := v_true_count + 1;
                ELSIF  v_regis_id != v_ans THEN
                    v_false_count := v_false_count + 1;
                END IF;
                END IF;
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('Question: ' || regisid_rec.question);
            DBMS_OUTPUT.PUT_LINE('Subject Code: ' || regisid_rec.subjectcode || ' Chapter: ' || regisid_rec.chapter 
                                 || ' Correct answer ID: ' || v_ans || ' User answer ID: ' || v_test);
            ----Count score----
            IF regisid_rec.answer = regisid_rec.testanswer THEN 
                v_correct_count := v_correct_count + 1;
                DBMS_OUTPUT.PUT_LINE('User answer is correct');
            ELSE
                DBMS_OUTPUT.PUT_LINE('User answer is uncorrect');
            END IF;
            v_maxscore := v_maxscore + 1;
            DBMS_OUTPUT.PUT_LINE('Other user answer correct: ' || v_true_count);
            DBMS_OUTPUT.PUT_LINE('Other user answer uncorrect: ' || v_false_count);
            DBMS_OUTPUT.PUT_LINE('-----Other user choose------');
            DBMS_OUTPUT.PUT_LINE(v_a_id || ' ' || v_a_count);
            DBMS_OUTPUT.PUT_LINE(v_b_id || ' ' || v_b_count);
            DBMS_OUTPUT.PUT_LINE(v_c_id || ' ' || v_c_count);
            DBMS_OUTPUT.PUT_LINE(v_d_id || ' ' || v_d_count);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Score of ' || regisid_rec.registrationno || ' is ' || v_correct_count || ' / ' ||  v_maxscore);
        CLOSE regisid_cur;
    END ANALYZE_TEST;

EXECUTE ANALYZE_TEST(300001);