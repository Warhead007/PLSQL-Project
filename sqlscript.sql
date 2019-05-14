create or replace PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE) IS
    v_correct_count NUMBER := 0;
    v_correct_count_chap NUMBER := 0;
    v_maxscore NUMBER := 0;
    v_maxscorechap NUMBER := 0;
    v_regissub VARCHAR2(20) := p_subcode;
    v_ans NUMBER := 0;
    v_test NUMBER := 0;
    v_chapter NUMBER := 1;
    CURSOR regissub_cur (p_subcode registration.subjectcode%TYPE) IS
        SELECT *
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
        WHERE qb.subjectcode = p_subcode
        ORDER BY qb.chapter ASC;
   CURSOR maxscorechap_cur (p_subcode registration.subjectcode%TYPE) IS
        SELECT *
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
        WHERE qb.subjectcode = p_subcode and qb.chapter = v_chapter;
    regisid_rec regissub_cur%ROWTYPE;    
    maxscorechap_rec maxscorechap_cur%ROWTYPE;
    BEGIN
        OPEN regissub_cur(p_subcode);
        DBMS_OUTPUT.PUT_LINE('Subject : ' || v_regissub);
        DBMS_OUTPUT.PUT_LINE('');
        LOOP
        FETCH regissub_cur INTO regisid_rec;
        EXIT WHEN regissub_cur%NOTFOUND;
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
        
        
        DBMS_OUTPUT.PUT_LINE('');
        END LOOP;

        CLOSE regissub_cur;
        
        
        --- Max Score each Chapter ---
    FOR i IN 1..3 LOOP    
        OPEN maxscorechap_cur(p_subcode);
        LOOP
        FETCH maxscorechap_cur INTO maxscorechap_rec;
        EXIT WHEN maxscorechap_cur%NOTFOUND ;
    ----Analysis answer----
        IF maxscorechap_rec.answer = 'A' THEN
            v_ans := maxscorechap_rec.a_id;
            CASE
                WHEN maxscorechap_rec.testanswer = 'A' THEN
                    v_test := maxscorechap_rec.a_id;
                WHEN maxscorechap_rec.testanswer = 'B' THEN
                    v_test := maxscorechap_rec.b_id;
                WHEN maxscorechap_rec.testanswer = 'C' THEN
                    v_test := maxscorechap_rec.c_id;
                ELSE
                    v_test := maxscorechap_rec.c_id;
            END CASE;
        ELSIF regisid_rec.answer = 'B' THEN
            v_ans := maxscorechap_rec.b_id;
            CASE
                WHEN maxscorechap_rec.testanswer = 'A' THEN
                    v_test := regisid_rec.a_id;
                WHEN maxscorechap_rec.testanswer = 'B' THEN
                    v_test := regisid_rec.b_id;
                WHEN maxscorechap_rec.testanswer = 'C' THEN
                    v_test := maxscorechap_rec.c_id;
                ELSE
                    v_test := maxscorechap_rec.c_id;
            END CASE;
        ELSIF regisid_rec.answer = 'C' THEN
            v_ans := maxscorechap_rec.c_id;
            CASE
                WHEN maxscorechap_rec.testanswer = 'A' THEN
                    v_test := maxscorechap_rec.a_id;
                WHEN maxscorechap_rec.testanswer = 'B' THEN
                    v_test := maxscorechap_rec.b_id;
                WHEN maxscorechap_rec.testanswer = 'C' THEN
                    v_test := maxscorechap_rec.c_id;
                ELSE
                    v_test := maxscorechap_rec.c_id;
            END CASE;
        ELSE
            v_ans := maxscorechap_rec.d_id;
            CASE
                WHEN maxscorechap_rec.testanswer = 'A' THEN
                    v_test := maxscorechap_rec.a_id;
                WHEN maxscorechap_rec.testanswer = 'B' THEN
                    v_test := maxscorechap_rec.b_id;
                WHEN maxscorechap_rec.testanswer = 'C' THEN
                    v_test := maxscorechap_rec.c_id;
                ELSE
                    v_test := maxscorechap_rec.c_id;
            END CASE;
        END IF;
        ----Count score----
        IF maxscorechap_rec.answer = maxscorechap_rec.testanswer THEN 
            v_correct_count_chap := v_correct_count_chap + 1;
        END IF;
        v_maxscorechap := v_maxscorechap + 1;
        
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Score of ' || regisid_rec.subjectcode || ' in chapter '|| v_chapter ||' is ' || v_correct_count_chap || ' / ' ||  v_maxscorechap);
        CLOSE maxscorechap_cur;
        v_chapter := v_chapter +1;
        v_maxscorechap := 0;
    END LOOP;    
        
        DBMS_OUTPUT.PUT_LINE('Score of ' || regisid_rec.subjectcode || ' is ' || v_correct_count || ' / ' ||  v_maxscore);
        
    END ANALYZE_TEST;
    
execute ANALYZE_TEST ('INT102');
set serveroutput on;
