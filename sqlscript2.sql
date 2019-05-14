create or replace PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE) IS
    v_correct_count NUMBER := 0;
    v_correct_count_chap NUMBER := 0;
    v_maxscore NUMBER := 0;
    v_maxscorechap NUMBER := 0;
    v_regissub VARCHAR2(20) := p_subcode;
    v_ans NUMBER := 0;
    v_test NUMBER := 0;
    v_chapter NUMBER := 1;
    v_true_count NUMBER := 0;
    v_false_count NUMBER := 0;
    v_question_id NUMBER DEFAULT 4331 ;
    CURSOR regissub_cur (p_subcode registration.subjectcode%TYPE) IS
        SELECT *
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
        WHERE qb.subjectcode = p_subcode
        ORDER BY qb.chapter,qt.REGISTRATIONNO ASC;
   CURSOR maxscorechap_cur (p_subcode registration.subjectcode%TYPE) IS 
        SELECT *
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
        WHERE qb.subjectcode = p_subcode and qb.chapter = v_chapter;
   CURSOR question_cur (p_subcode registration.subjectcode%TYPE) IS 
        SELECT *
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
        WHERE qb.subjectcode = p_subcode
            AND qt.questionid = v_question_id;
   CURSOR maxchap_cur (p_subcode registration.subjectcode%TYPE) IS 
        SELECT MAX(chapter)
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
        WHERE qb.subjectcode = p_subcode ;  
   CURSOR maxquestion_cur (p_subcode registration.subjectcode%TYPE) IS 
        SELECT *
        FROM questionbank qb
        WHERE qb.subjectcode = p_subcode
            and qb.chapter = v_chapter; 
    regisid_rec regissub_cur%ROWTYPE;    
    maxscorechap_rec maxscorechap_cur%ROWTYPE;
    question_rec question_cur%ROWTYPE ;
    maxquestion_rec maxquestion_cur%ROWTYPE ;
    
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
                             || ' Correct answer ID: ' || v_ans || ' User ID :  ' ||regisid_rec.REGISTRATIONNO ||' User answer ID: ' || v_test);
                             
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
   
     
        
    --- Count Correct or Wrong ---
    FOR i IN 1..3 LOOP 
    DBMS_OUTPUT.PUT_LINE('------------------------');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Chapter : ' || v_chapter);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('------------------------');
    DBMS_OUTPUT.PUT_LINE('');
        OPEN maxquestion_cur(p_subcode);
                LOOP
                FETCH maxquestion_cur INTO maxquestion_rec;
                EXIT WHEN maxquestion_cur%NOTFOUND ; 
            OPEN question_cur(p_subcode);
                LOOP
                FETCH question_cur INTO question_rec;
                EXIT WHEN question_cur%NOTFOUND ;
    ----Analysis answer----
                IF question_rec.answer = 'A' THEN
                    v_ans := question_rec.a_id;
                    CASE
                        WHEN question_rec.testanswer = 'A' THEN
                            v_test := question_rec.a_id;
                        WHEN question_rec.testanswer = 'B' THEN
                            v_test :=question_rec.b_id;
                        WHEN question_rec.testanswer = 'C' THEN
                            v_test := question_rec.c_id;
                        ELSE
                            v_test := question_rec.c_id;
                    END CASE;
                ELSIF question_rec.answer = 'B' THEN
                    v_ans := question_rec.b_id;
                    CASE
                        WHEN question_rec.testanswer = 'A' THEN
                            v_test := question_rec.a_id;
                        WHEN question_rec.testanswer = 'B' THEN
                            v_test := question_rec.b_id;
                        WHEN question_rec.testanswer = 'C' THEN
                            v_test := question_rec.c_id;
                        ELSE
                            v_test := question_rec.c_id;
                    END CASE;
                ELSIF question_rec.answer = 'C' THEN
                    v_ans := question_rec.c_id;
                    CASE
                        WHEN question_rec.testanswer = 'A' THEN
                            v_test := question_rec.a_id;
                        WHEN question_rec.testanswer = 'B' THEN
                            v_test := question_rec.b_id;
                        WHEN question_rec.testanswer = 'C' THEN
                            v_test := question_rec.c_id;
                        ELSE
                            v_test := question_rec.c_id;
                    END CASE;
                ELSE
                    v_ans := question_rec.d_id;
                    CASE
                        WHEN question_rec.testanswer = 'A' THEN
                            v_test := question_rec.a_id;
                        WHEN question_rec.testanswer = 'B' THEN
                            v_test := question_rec.b_id;
                        WHEN question_rec.testanswer = 'C' THEN
                            v_test := question_rec.c_id;
                        ELSE
                            v_test := question_rec.c_id;
                        END CASE;
                END IF;
         

        ---- Count Correct or Incorrect ----
                IF question_rec.answer = question_rec.testanswer THEN 
                    v_true_count := v_true_count + 1 ;
                ELSE
                    v_false_count := v_false_count + 1 ;
                END IF;
                    v_true_count := 0;
                    v_false_count := 0 ;
                END LOOP;
                    DBMS_OUTPUT.PUT_LINE('Question: ' || maxquestion_rec.questionid );
                    DBMS_OUTPUT.PUT_LINE('Question: ' || question_rec.question );
                    DBMS_OUTPUT.PUT_LINE(' Correct answer : ' || question_rec.answer);
                    DBMS_OUTPUT.PUT_LINE('Number of Correct answer : ' || v_true_count);
                    DBMS_OUTPUT.PUT_LINE('Number of Incorrect answer : ' || v_false_count);
                    DBMS_OUTPUT.PUT_LINE('');
                
                CLOSE question_cur;
                v_question_id := v_question_id + 1;
                
        END LOOP; 
        CLOSE maxquestion_cur;    
        v_chapter := v_chapter + 1;
    END LOOP;     
        DBMS_OUTPUT.PUT_LINE('');
        v_chapter := 1;
        
        DBMS_OUTPUT.PUT_LINE('');
        
        
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
            ELSIF maxscorechap_rec.answer = 'B' THEN
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
            ELSIF maxscorechap_rec.answer = 'C' THEN
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
        v_correct_count_chap := 0;
    END LOOP;    
        DBMS_OUTPUT.PUT_LINE('Total score of ' || regisid_rec.subjectcode || ' is ' || v_correct_count || ' / ' ||  v_maxscore);
    
            
    END ANALYZE_TEST;
    
execute ANALYZE_TEST ('INT102');
set serveroutput on;

--- Test Logic ---
SELECT COUNT(*)
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
         WHERE qb.subjectcode = 'INT102'
         AND qt.questionid = '4334';
         
SELECT MAX(qb.chapter)
        FROM questiontest qt
        JOIN questionbank qb on qt.questionid = qb.questionid
         WHERE qb.subjectcode = 'INT102';         
         
SELECT COUNT(qb.questionid)
        FROM questionbank qb
        WHERE qb.subjectcode = 'INT102'
            and qb.chapter = '1';          
