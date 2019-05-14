SET serveroutput ON;

CREATE OR REPLACE  PROCEDURE ANALYZE_TEST(p_registrationno registration.registrationno%TYPE) IS
    v_correct_count NUMBER := 0;
    v_maxscore NUMBER := 0;
    v_regisnum NUMBER := p_registrationno;
    v_sub registration.subjectcode%TYPE;
    v_ans NUMBER := 0;
    v_test NUMBER := 0;
    v_ans_text answerbank.answer%TYPE;
    v_test_text answerbank.answer%TYPE;
    v_a_text answerbank.answer%TYPE;
    v_b_text answerbank.answer%TYPE;
    v_c_text answerbank.answer%TYPE;
    v_d_text answerbank.answer%TYPE;
    CURSOR regisid_cur (p_registrationno_cur registration.registrationno%TYPE) IS
        SELECT r.subjectcode,r.testdate,qt.a_id,qt.b_id,qt.c_id,qt.d_id,qt.answer,
        qt.testanswer,qb.chapter,qt.questionid,qb.question,qt.registrationno
        FROM questiontest qt
        JOIN questionbank qb ON qt.questionid = qb.questionid
        JOIN registration r ON r.registrationno = qt.registrationno
        WHERE qt.registrationno = p_registrationno;
    regisid_rec regisid_cur%ROWTYPE;
    
    v_other_ques NUMBER := 0;
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
        SELECT r.subjectcode,r.testdate,qt.a_id,qt.b_id,qt.c_id,qt.d_id,qt.answer,qt.testanswer,qt.questionid,qb.question
        FROM registration r
        JOIN questiontest qt ON r.registrationno = qt.registrationno
        JOIN questionbank qb ON qt.questionid = qb.questionid;
    
BEGIN
    SELECT subjectcode INTO v_sub
    FROM registration
    WHERE registrationno = p_registrationno;
    OPEN regisid_cur(p_registrationno);
    DBMS_OUTPUT.PUT_LINE('Registation ID: ' || v_regisnum);
    DBMS_OUTPUT.PUT_LINE('Subject: ' || v_sub);
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
            
        v_true_count := 0;
        v_false_count := 0;
            
        v_a_count := 0;
        v_b_count := 0;
        v_c_count := 0;
        v_d_count := 0;
            
        FOR other_regis_rec IN other_regis_cur LOOP
            IF regisid_rec.subjectcode = other_regis_rec.subjectcode
            AND regisid_rec.testdate = other_regis_rec.testdate
            AND regisid_rec.questionid = other_regis_rec.questionid THEN
            v_a_id := regisid_rec.a_id;
            v_b_id := regisid_rec.b_id;
            v_c_id := regisid_rec.c_id;
            v_d_id := regisid_rec.d_id;
            CASE
                WHEN other_regis_rec.testanswer = 'A' THEN
                    v_regis_id := other_regis_rec.a_id;
                WHEN other_regis_rec.testanswer = 'B' THEN
                    v_regis_id := other_regis_rec.b_id;    
                WHEN other_regis_rec.testanswer = 'C' THEN
                    v_regis_id := other_regis_rec.c_id;
                ELSE
                    v_regis_id := other_regis_rec.d_id;
            END CASE;
            CASE
                WHEN v_regis_id = v_a_id THEN
                    v_a_count := v_a_count + 1;
                WHEN v_regis_id = v_b_id THEN
                    v_b_count := v_b_count + 1;
                WHEN v_regis_id = v_c_id THEN
                    v_c_count := v_c_count + 1;
                ELSE
                    v_d_count := v_d_count + 1;
                END CASE;
            IF v_regis_id = v_ans THEN
                v_true_count := v_true_count + 1;
            ELSIF  v_regis_id != v_ans THEN
                v_false_count := v_false_count + 1;
            END IF;
                v_other_ques := other_regis_rec.questionid;
            END IF;
        END LOOP;
            
        SELECT answer INTO v_ans_text
        FROM answerbank
        WHERE answerid = v_ans;
        SELECT answer INTO v_test_text
        FROM answerbank
        WHERE answerid = v_test;
            
        SELECT answer INTO v_a_text
        FROM answerbank
        WHERE answerid = v_a_id;
        SELECT answer INTO v_b_text
        FROM answerbank
        WHERE answerid = v_b_id;
        SELECT answer INTO v_c_text
        FROM answerbank
        WHERE answerid = v_c_id;
        SELECT answer INTO v_d_text
        FROM answerbank
        WHERE answerid = v_d_id;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Chapter: ' || regisid_rec.chapter);
        DBMS_OUTPUT.PUT_LINE('Question: ' || regisid_rec.question);
        DBMS_OUTPUT.PUT_LINE('Correct answer: ' || v_ans_text);
        DBMS_OUTPUT.PUT_LINE('User answer: ' || v_test_text);
        ----Count score----
        IF regisid_rec.answer = regisid_rec.testanswer THEN 
            v_correct_count := v_correct_count + 1;
            DBMS_OUTPUT.PUT_LINE('User answer is correct');
        ELSE
            DBMS_OUTPUT.PUT_LINE('User answer is uncorrect');
        END IF;
        v_maxscore := v_maxscore + 1;
        DBMS_OUTPUT.PUT_LINE('-----All users result------');
        DBMS_OUTPUT.PUT_LINE('All users answer correct: ' || v_true_count);
        DBMS_OUTPUT.PUT_LINE('All users answer uncorrect: ' || v_false_count);
        DBMS_OUTPUT.PUT_LINE('-----All users choose------');
        SORT_ANSWER(v_a_text,v_b_text,v_c_text,v_d_text,v_a_count,v_b_count,v_c_count,v_d_count);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Score of ' || regisid_rec.registrationno || ' is ' || v_correct_count || ' / ' ||  v_maxscore);
    CLOSE regisid_cur;
END ANALYZE_TEST;

CREATE TYPE answer_obj IS OBJECT(
    count_value NUMBER,
    text_value VARCHAR2(4000));
/
CREATE TYPE answer_table IS TABLE OF answer_obj;
/
CREATE OR REPLACE  PROCEDURE SORT_ANSWER (p_a_text answerbank.answer%TYPE,p_b_text answerbank.answer%TYPE,
                                          p_c_text answerbank.answer%TYPE,p_d_text answerbank.answer%TYPE,
                                          p_a_count NUMBER,p_b_count NUMBER,p_c_count NUMBER,p_d_count NUMBER) IS
    
    answer_unsort answer_table := answer_table();
    answer_sort answer_table := answer_table();
    v_count NUMBER := 0; 
BEGIN
    answer_unsort.EXTEND(4);
    
    answer_unsort(1) := answer_obj(p_a_count,p_a_text);
    answer_unsort(2) := answer_obj(p_b_count,p_b_text);
    answer_unsort(3) := answer_obj(p_c_count,p_c_text);
    answer_unsort(4) := answer_obj(p_d_count,p_d_text);
    
    SELECT CAST(MULTISET(SELECT *
                FROM TABLE(answer_unsort)
                ORDER BY 1 DESC)AS answer_table)
    INTO answer_sort
    FROM DUAL;
     v_count := answer_sort.COUNT();
    FOR i IN 1..v_count LOOP
        DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : ' || answer_sort(i).count_value);
    END LOOP;
END SORT_ANSWER;

EXECUTE ANALYZE_TEST(300002);