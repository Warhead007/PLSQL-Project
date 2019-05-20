SET serveroutput ON;
----Create type to collect answer for question----
CREATE TYPE answer_obj_test IS OBJECT(
id_value NUMBER,
text_value VARCHAR2(4000),
count_value NUMBER);
/
----Table for keep answer in array----
CREATE TYPE answer_table_test IS TABLE OF answer_obj_test;
/
----------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PACKAGE_ANALYSIS IS
    ----Create type to collect answer for question----  
    PROCEDURE ANALYZE_TEST(p_registrationno registration.registrationno%TYPE);
    PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE);
    PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE,
                           p_testdate registration.testdate%TYPE);
END PACKAGE_ANALYSIS;
----------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PACKAGE_ANALYSIS IS   

    PROCEDURE SORT_ANSWER (p_questionid IN questionbank.question%TYPE,
                           p_subcode IN registration.subjectcode%TYPE,
                           p_count_all_answer OUT NUMBER,
                           p_testdate IN registration.testdate%TYPE DEFAULT NULL);
    FUNCTION CHECK_ANSWER(p_questionid questionbank.questionid%TYPE,
                          p_answer answerbank.answer%TYPE,
                          p_regisid registration.registrationno%TYPE) RETURN NUMBER;
    FUNCTION MAX_CHAPTER(p_subcode questionbank.subjectcode%TYPE) RETURN NUMBER;

    PROCEDURE ANALYZE_TEST(p_registrationno registration.registrationno%TYPE) IS
        v_maxscore NUMBER := 0;
        v_regisnum NUMBER := p_registrationno;
        v_sub registration.subjectcode%TYPE;
        v_ans NUMBER := 0;
        v_test NUMBER := 0;
        v_ans_text answerbank.answer%TYPE;
        v_test_text answerbank.answer%TYPE;
        v_correct NUMBER := 0;
        ----Cursor for query select registrationno question and answer----
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
        ----Cursor for query other question and answer----
        CURSOR other_regis_cur IS
            SELECT r.subjectcode,r.testdate,qt.a_id,qt.b_id,qt.c_id,qt.d_id,
                   qt.answer,qt.testanswer,qt.questionid,qb.question,qt.registrationno
            FROM registration r
            JOIN questiontest qt ON r.registrationno = qt.registrationno
            JOIN questionbank qb ON qt.questionid = qb.questionid;
        v_only_store_value NUMBER;
        
    BEGIN
        ----Select subjectcode for show----
        SELECT subjectcode INTO v_sub
        FROM registration
        WHERE registrationno = p_registrationno;
        ----Select correct score of registrater----
        SELECT COUNT(questionid) INTO v_correct
        FROM questiontest
        WHERE answer = testanswer
        AND registrationno = p_registrationno;
        ----Select max score of registrater----
        SELECT COUNT(questionid) INTO v_maxscore
        FROM questiontest
        WHERE registrationno = p_registrationno;
        
        OPEN regisid_cur(p_registrationno);
        DBMS_OUTPUT.PUT_LINE('Registation ID: ' || v_regisnum);
        DBMS_OUTPUT.PUT_LINE('Subject: ' || v_sub);
        DBMS_OUTPUT.PUT_LINE('Score of ' || v_regisnum || ' is ' || v_correct || ' / ' ||  v_maxscore);
        ----Loop for query select register question----
        LOOP
            FETCH regisid_cur INTO regisid_rec;
            EXIT WHEN regisid_cur%NOTFOUND;
            ----Take answer of question----
            v_ans := CHECK_ANSWER(regisid_rec.questionid,
                                  regisid_rec.testanswer,
                                  regisid_rec.registrationno);
            ----Take user answer----
            v_test := CHECK_ANSWER(regisid_rec.questionid,
                                   regisid_rec.testanswer,
                                   regisid_rec.registrationno);
            v_true_count := 0;
            v_false_count := 0;
            
            ----Loop for query other user who have same question----
            ----Create function----
            FOR other_regis_rec IN other_regis_cur LOOP
                IF regisid_rec.questionid = other_regis_rec.questionid
                AND regisid_rec.testdate = other_regis_rec.testdate
                AND other_regis_rec.answer = other_regis_rec.testanswer THEN
                    v_true_count := v_true_count + 1;
                ELSIF regisid_rec.questionid = other_regis_rec.questionid
                AND regisid_rec.testdate = other_regis_rec.testdate
                AND other_regis_rec.answer != other_regis_rec.testanswer THEN
                    v_false_count := v_false_count + 1;
                END IF;
             END LOOP;
                
            ----Select answer text from answer id----
            SELECT answer INTO v_test_text
            FROM answerbank 
            WHERE answerid = v_test;
            
            SELECT answer INTO v_ans_text
            FROM answerbank 
            WHERE answerid = v_ans;
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Chapter: ' || regisid_rec.chapter);
            DBMS_OUTPUT.PUT_LINE('['||regisid_rec.questionid|| '] ' ||'Question: ' || regisid_rec.question);
            DBMS_OUTPUT.PUT_LINE('User answer : ' || '{ ' || v_test_text || ' }');
            ----Count score of select user----
            IF regisid_rec.answer = regisid_rec.testanswer THEN 
                DBMS_OUTPUT.PUT_LINE('User answer is { correct }');
                DBMS_OUTPUT.PUT_LINE('');
            ELSE
                DBMS_OUTPUT.PUT_LINE('User answer is { uncorrect }');
                DBMS_OUTPUT.PUT_LINE('');
            END IF;
            DBMS_OUTPUT.PUT_LINE('-----All users result------');
            DBMS_OUTPUT.PUT_LINE('All users answer correct : ' || '{' || v_true_count || '}');
            DBMS_OUTPUT.PUT_LINE('All users answer uncorrect : ' || '{' || v_false_count|| '}');
            DBMS_OUTPUT.PUT_LINE('---------------------------');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('-----All users choose------');
            SORT_ANSWER(regisid_rec.questionid,regisid_rec.subjectcode,v_only_store_value,regisid_rec.testdate);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;
        CLOSE regisid_cur;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'Invalid data. Plase try again.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002,'Something went wrong. Plase try again.');
    END ANALYZE_TEST;
    
    
    
    --- Subject Code ---
    PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE) IS
        ----Cursor for query question----
        CURSOR question_cur (p_chapter questionbank.chapter%TYPE) IS
            SELECT DISTINCT qt.questionid,qb.question
            FROM questionbank qb
            JOIN questiontest qt ON qt.questionid = qb.questionid
            WHERE subjectcode = p_subcode AND chapter = p_chapter
            ORDER BY qt.questionid;
        question_rec question_cur%ROWTYPE;
        
        v_ans NUMBER := 0;
        v_true_question NUMBER := 0;
        v_false_question NUMBER := 0;
        v_all_score_pre_question NUMBER := 0;
        v_max_chapter NUMBER := 0;
        v_subjectcode registration.subjectcode%TYPE := p_subcode;
    BEGIN
        v_max_chapter := MAX_CHAPTER(p_subcode);
        DBMS_OUTPUT.PUT_LINE('Subject: ' || p_subcode);
        ----Loop for query pre chapter----
        FOR i IN 1..v_max_chapter LOOP
            OPEN question_cur(i);
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Chapter: ' || i);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            LOOP
                v_true_question := 0;
                v_false_question := 0;
                v_all_score_pre_question := 0;
                FETCH question_cur INTO question_rec;
                ----Select for count correct question----
                SELECT COUNT(registrationno) INTO v_true_question
                FROM questiontest
                WHERE questionid = question_rec.questionid  AND answer = testanswer;
    
                EXIT WHEN question_cur%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('-------------------------------------');
                DBMS_OUTPUT.PUT_LINE('[' ||question_rec.questionid || ']' || '  ' || question_rec.question);
                DBMS_OUTPUT.PUT_LINE('--- User answer --- ');
                SORT_ANSWER(question_rec.questionid,p_subcode,v_all_score_pre_question);
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('[Number of correct and incorrect answer]');
                DBMS_OUTPUT.PUT_LINE('User correct answer: ' || ' {' || v_true_question 
                                     || ' / ' || v_all_score_pre_question || '} ');
                v_false_question := v_all_score_pre_question - v_true_question;
                DBMS_OUTPUT.PUT_LINE('User uncorrect answer: ' || ' {' || v_false_question 
                                    || ' / ' || v_all_score_pre_question || '} ');
                DBMS_OUTPUT.PUT_LINE('-------------------------------------');
                DBMS_OUTPUT.PUT_LINE('');
    
            END LOOP;
            CLOSE question_cur;
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'Invalid data. Plase try again.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002,'Something went wrong. Plase try again.');
    END ANALYZE_TEST; 



--- Subject Code and Test Date ---    
    PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE,
                           p_testdate registration.testdate%TYPE) IS
        ----Cursor for query question----
        CURSOR question_cur (p_chapter questionbank.chapter%TYPE) IS
            SELECT DISTINCT qb.questionid
            FROM questionbank qb
            JOIN questiontest qt ON qt.questionid = qb.questionid
            JOIN registration r ON r.registrationno = qt.registrationno
            WHERE qb.subjectcode = p_subcode 
            AND qb.chapter = p_chapter 
            AND r.testdate = p_testdate;
        question_rec question_cur%ROWTYPE;
        
        v_regisid NUMBER := 0;
        v_question questionbank.question%TYPE;
        v_ans NUMBER := 0;
        v_true_question NUMBER := 0;
        v_false_question NUMBER := 0;
        v_all_score_pre_question NUMBER := 0;
        v_max_chapter NUMBER := 0;
        v_subjectcode registration.subjectcode%TYPE := p_subcode;
    BEGIN
        v_max_chapter := MAX_CHAPTER(p_subcode);
        DBMS_OUTPUT.PUT_LINE('Subject: ' || p_subcode || ' Date: ' || p_testdate);
        ----Loop for print pre chapter----
        FOR i IN 1..v_max_chapter LOOP 
            OPEN question_cur(i);
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Chapter: ' || i);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            LOOP
                v_true_question := 0;
                v_false_question := 0;
                v_all_score_pre_question := 0;
                FETCH question_cur INTO question_rec;
                ----Select for count correct question----
                SELECT COUNT(r.registrationno) INTO v_true_question
                FROM questiontest qt
                JOIN registration r ON r.registrationno = qt.registrationno
                WHERE qt.questionid = question_rec.questionid
                AND qt.answer = qt.testanswer
                AND r.testdate = p_testdate;
                EXIT WHEN question_cur%NOTFOUND;
                ----Select for query only one question in this loop----
                SELECT question INTO v_question
                FROM questionbank
                WHERE questionid = question_rec.questionid;
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('-------------------------------------');
                DBMS_OUTPUT.PUT_LINE('['|| question_rec.questionid ||']' ||'  ' || v_question);
                DBMS_OUTPUT.PUT_LINE('--- User answer --- ');
                SORT_ANSWER(question_rec.questionid,p_subcode,v_all_score_pre_question,p_testdate);
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('[Number of correct and incorrect answer]');
                DBMS_OUTPUT.PUT_LINE('User correct answer: ' ||' {' || v_true_question 
                                     || ' / ' || v_all_score_pre_question|| '}');
                v_false_question := v_all_score_pre_question - v_true_question;
                DBMS_OUTPUT.PUT_LINE('User uncorrect answer: ' ||' {' ||v_false_question 
                                     || ' / ' || v_all_score_pre_question || '}');
                DBMS_OUTPUT.PUT_LINE('-------------------------------------');
                DBMS_OUTPUT.PUT_LINE('');
            END LOOP;
            CLOSE question_cur;
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'Invalid data. Plase try again.');
--        WHEN OTHERS THEN
--            RAISE_APPLICATION_ERROR(-20002,'Something went wrong. Plase try again.');
    END ANALYZE_TEST;
    
    ----Procedure for query answer per question, count per answer user choose----
    
    PROCEDURE SORT_ANSWER (p_questionid IN questionbank.question%TYPE,
                           p_subcode IN registration.subjectcode%TYPE,
                           p_count_all_answer OUT NUMBER,
                           p_testdate IN registration.testdate%TYPE DEFAULT NULL) IS   
        v_correct_answer_type NUMBER := 1;
        v_uncorrect_answer_type NUMBER := 2;
        
        answer_unsort answer_table_test := answer_table_test();
        answer_sort answer_table_test := answer_table_test();
        
        v_count NUMBER := 0;
        v_count_answer NUMBER := 0;
        v_count_answer_choose NUMBER := 0;
        v_ans NUMBER := 0;
        v_test NUMBER := 0;
        v_count_loop NUMBER := 0;
        v_answer_check NUMBER := 0;
        ----Cursor for query question of questiontest----
        CURSOR other_regis_cur IS
            SELECT qt.questionid,qt.testanswer,qt.answer,r.subjectcode,r.testdate,qt.registrationno
            FROM registration r
            JOIN questiontest qt ON r.registrationno = qt.registrationno
            JOIN questionbank qb ON qt.questionid = qb.questionid;
        ----Cursor for query answer pre question----
        CURSOR answer_cur IS
            SELECT answerid,answer
            FROM answerbank
            WHERE questionid =  p_questionid;
        answer_rec answer_cur%ROWTYPE;
    BEGIN    
        p_count_all_answer := 0;
        OPEN answer_cur;
        
        ----Count answer for loop round----
        SELECT COUNT(answerid) INTO v_count_answer
        FROM answerbank
        WHERE questionid =  p_questionid;
        answer_unsort.EXTEND(v_count_answer);
        ----Loop to find answer of question and store in answer_unsort----
        FOR i IN 1..v_count_answer LOOP
            FETCH answer_cur INTO answer_rec;
            answer_unsort(i) := answer_obj_test(answer_rec.answerid,answer_rec.answer,0);
            v_count_answer_choose := 0;
            ----Loop for count each answer at user select----
            FOR other_regis_rec IN other_regis_cur LOOP
                IF p_testdate IS NULL THEN
                    IF other_regis_rec.subjectcode = p_subcode THEN
                        v_test := CHECK_ANSWER(other_regis_rec.questionid,
                                               other_regis_rec.testanswer,
                                               other_regis_rec.registrationno);
                    IF v_test = answer_unsort(i).id_value THEN 
                        v_count_answer_choose := v_count_answer_choose + 1;
                        p_count_all_answer := p_count_all_answer + 1;
                    END IF;
                    answer_unsort(i) := answer_obj_test(answer_unsort(i).id_value,
                                                        answer_unsort(i).text_value,
                                                        v_count_answer_choose);
                    END IF;
                ELSE
                    IF other_regis_rec.subjectcode = p_subcode 
                    AND other_regis_rec.testdate = p_testdate THEN
                        v_test := CHECK_ANSWER(other_regis_rec.questionid,
                                               other_regis_rec.testanswer,
                                               other_regis_rec.registrationno);
                        IF v_test = answer_unsort(i).id_value THEN 
                            v_count_answer_choose := v_count_answer_choose + 1;
                            p_count_all_answer := p_count_all_answer + 1;
                        END IF;
                        ----Store count select answer----
                        answer_unsort(i) := answer_obj_test(answer_unsort(i).id_value,
                                                            answer_unsort(i).text_value,
                                                            v_count_answer_choose);
                    END IF; 
                END IF;
            END LOOP;
        END LOOP;
        ----Select to sorting----
        SELECT CAST(MULTISET(SELECT *
                    FROM TABLE(answer_unsort)
                    ORDER BY 3 DESC)AS answer_table_test)
        INTO answer_sort
        FROM DUAL;
        v_count := answer_sort.COUNT();
        ----Print answer each question----
        FOR i IN 1..v_count LOOP
            SELECT answertype INTO v_answer_check 
            FROM answerbank
            WHERE answerid = answer_sort(i).id_value;
            IF v_answer_check = v_correct_answer_type THEN
                DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : '
                                     || answer_sort(i).count_value || ' is answer correct.');
            ELSIF v_answer_check = v_uncorrect_answer_type THEN
                DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : '
                                     || answer_sort(i).count_value || ' is answer uncorrect.');
            END IF;
        END LOOP;
    CLOSE answer_cur;
    END SORT_ANSWER;
    
    ----Funtion for check answer for match an answer id and return answer id---- 
    FUNCTION CHECK_ANSWER(p_questionid questionbank.questionid%TYPE,
                          p_answer answerbank.answer%TYPE,
                          p_regisid registration.registrationno%TYPE)
    RETURN NUMBER IS
        v_test NUMBER := 0;
        v_a_id NUMBER := 0;
        v_b_id NUMBER := 0;
        v_c_id NUMBER := 0;
        v_d_id NUMBER := 0;
    BEGIN 
        SELECT a_id,b_id,c_id,d_id INTO v_a_id,v_b_id,v_c_id,v_d_id
        FROM questiontest
        WHERE questionid = p_questionid
        AND registrationno = p_regisid;
        CASE
            WHEN p_answer = 'A' THEN
                v_test := v_a_id;
            WHEN p_answer = 'B' THEN
                v_test := v_b_id;
            WHEN p_answer = 'C' THEN
                v_test := v_c_id;
            ELSE
                v_test := v_d_id;
        END CASE;
        RETURN v_test;
    END CHECK_ANSWER;
    
    FUNCTION MAX_CHAPTER(p_subcode questionbank.subjectcode%TYPE) RETURN NUMBER IS
        v_max_chapter NUMBER;    
    BEGIN
        SELECT MAX(chapter) INTO v_max_chapter
        FROM questionbank
        WHERE subjectcode = p_subcode;
        RETURN v_max_chapter;
    END MAX_CHAPTER;
END PACKAGE_ANALYSIS;

EXECUTE PACKAGE_ANALYSIS.ANALYZE_TEST(300003);

EXECUTE PACKAGE_ANALYSIS.ANALYZE_TEST('INT102');

EXECUTE PACKAGE_ANALYSIS.ANALYZE_TEST('INT102','01-MAY-2019');
