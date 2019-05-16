SET serveroutput ON;
TYPE answer_obj_test IS OBJECT(
id_value NUMBER,
text_value VARCHAR2(4000),
count_value NUMBER);
/   
TYPE answer_table_test IS TABLE OF answer_obj_test;
/
CREATE OR REPLACE PACKAGE PACKAGE_ANALYSIS IS
    PROCEDURE ANALYZE_TEST(p_registrationno registration.registrationno%TYPE);
    PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE);
    PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE,
                           p_testdate registration.testdate%TYPE);
END PACKAGE_ANALYSIS;
----------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PACKAGE_ANALYSIS IS   
    PROCEDURE SORT_ANSWER_1 (p_questionid questionbank.question%TYPE,
                             p_testdate registration.testdate%TYPE,
                             p_subcode registration.subjectcode%TYPE);
    PROCEDURE SORT_ANSWER_2 (p_questionid IN questionbank.question%TYPE,
                             p_subcode IN registration.subjectcode%TYPE,
                             p_count_all_answer OUT NUMBER);
    PROCEDURE SORT_ANSWER_3 (p_questionid IN questionbank.question%TYPE,
                             p_subcode IN registration.subjectcode%TYPE,
                             p_testdate IN registration.testdate%TYPE,
                             p_count_all_answer OUT NUMBER);
    
    PROCEDURE ANALYZE_TEST(p_registrationno registration.registrationno%TYPE) IS
        v_correct_count NUMBER := 0;
        v_maxscore NUMBER := 0;
        v_regisnum NUMBER := p_registrationno;
        v_sub registration.subjectcode%TYPE;
        v_ans NUMBER := 0;
        v_test NUMBER := 0;
        v_ans_text answerbank.answer%TYPE;
        v_test_text answerbank.answer%TYPE;
    
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
    
        CURSOR other_regis_cur IS
            SELECT r.subjectcode,r.testdate,qt.a_id,qt.b_id,qt.c_id,qt.d_id,
                   qt.answer,qt.testanswer,qt.questionid,qb.question,qt.registrationno
            FROM registration r
            JOIN questiontest qt ON r.registrationno = qt.registrationno
            JOIN questionbank qb ON qt.questionid = qb.questionid;
        
    BEGIN
        ----Select subject code for show----
        SELECT subjectcode INTO v_sub
        FROM registration
        WHERE registrationno = p_registrationno;
        OPEN regisid_cur(p_registrationno);
        DBMS_OUTPUT.PUT_LINE('Registation ID: ' || v_regisnum);
        DBMS_OUTPUT.PUT_LINE('Subject: ' || v_sub);
        DBMS_OUTPUT.PUT_LINE('');
        ----Loop for query select's register question----
        LOOP
            FETCH regisid_cur INTO regisid_rec;
            EXIT WHEN regisid_cur%NOTFOUND;
            ----Analysis answer of select's register----
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
            
            ----Loop for query other user who have same question----
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
            DBMS_OUTPUT.PUT_LINE('Chapter: ' || regisid_rec.chapter);
            DBMS_OUTPUT.PUT_LINE('Question: ' || regisid_rec.question);
            DBMS_OUTPUT.PUT_LINE('User answer: ' || v_test_text);
            ----Count score of select's user----
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
            SORT_ANSWER_1(regisid_rec.questionid,regisid_rec.testdate,regisid_rec.subjectcode);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Score of ' || regisid_rec.registrationno || ' is ' || v_correct_count || ' / ' ||  v_maxscore);
        CLOSE regisid_cur;
    END ANALYZE_TEST;
    
    PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE) IS
        
        CURSOR question_cur (p_chapter questionbank.chapter%TYPE) IS
            SELECT questionid,question
            FROM questionbank
            WHERE subjectcode = p_subcode AND chapter = p_chapter;
        question_rec question_cur%ROWTYPE;
        
        v_ans NUMBER := 0;
        v_true_question NUMBER := 0;
        v_false_question NUMBER := 0;
        v_all_score_pre_question NUMBER := 0;
        v_max_chapter NUMBER := 0;
        v_subjectcode registration.subjectcode%TYPE := p_subcode;
        v_true_subject NUMBER := 0;
        v_all_score_subject NUMBER := 0;
        v_true_chapter NUMBER := 0;
        v_all_score_pre_chapter NUMBER := 0;
    BEGIN
        SELECT MAX(chapter) INTO v_max_chapter
        FROM questionbank
        WHERE subjectcode = p_subcode;
        DBMS_OUTPUT.PUT_LINE('Subject: ' || p_subcode);
        
        FOR i IN 1..v_max_chapter LOOP
            v_true_chapter := 0;
            v_all_score_pre_chapter := 0;
            OPEN question_cur(i);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Chapter: ' || i);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            LOOP
                v_true_question := 0;
                v_false_question := 0;
                v_all_score_pre_question := 0;
                FETCH question_cur INTO question_rec;
                
                SELECT COUNT(registrationno) INTO v_true_question
                FROM questiontest
                WHERE questionid = question_rec.questionid  AND answer = testanswer;
    
                EXIT WHEN question_cur%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE(question_rec.questionid || '  ' || question_rec.question);
                SORT_ANSWER_2(question_rec.questionid,p_subcode,v_all_score_pre_question);
                DBMS_OUTPUT.PUT_LINE('User correct answer: ' || v_true_question 
                                     || ' / ' || v_all_score_pre_question);
                v_false_question := v_all_score_pre_question - v_true_question;
                v_true_subject := v_true_subject + v_true_question;
                v_true_chapter := v_true_chapter + v_true_question;
                v_all_score_pre_chapter := v_all_score_pre_chapter + v_all_score_pre_question;
                v_all_score_subject := v_all_score_subject + v_all_score_pre_question;
                DBMS_OUTPUT.PUT_LINE('User uncorrect answer: ' || v_false_question 
                                    || ' / ' || v_all_score_pre_question);
                DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('Score of Chapter: ' || i || ' '
                                 || v_true_chapter || ' / ' || v_all_score_pre_chapter);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            CLOSE question_cur;
        END LOOP;
            DBMS_OUTPUT.PUT_LINE('Score of subject ' || p_subcode
                                 || ': ' || v_true_subject 
                                 || ' / ' || v_all_score_subject);
    END ANALYZE_TEST; 
    
    PROCEDURE ANALYZE_TEST(p_subcode registration.subjectcode%TYPE,
                           p_testdate registration.testdate%TYPE) IS
        
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
        v_true_subject NUMBER := 0;
        v_all_score_subject NUMBER := 0;
        v_true_chapter NUMBER := 0;
        v_all_score_pre_chapter NUMBER := 0;
    BEGIN
        SELECT MAX(chapter) INTO v_max_chapter
        FROM questionbank
        WHERE subjectcode = p_subcode;
        DBMS_OUTPUT.PUT_LINE('Subject: ' || p_subcode || ' Date: ' || p_testdate);
        
        FOR i IN 1..v_max_chapter LOOP
            
            v_true_chapter := 0;
            v_all_score_pre_chapter := 0;
            OPEN question_cur(i);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Chapter: ' || i);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            LOOP
                v_true_question := 0;
                v_false_question := 0;
                v_all_score_pre_question := 0;
                FETCH question_cur INTO question_rec;
                
                SELECT COUNT(r.registrationno) INTO v_true_question
                FROM questiontest qt
                JOIN registration r ON r.registrationno = qt.registrationno
                WHERE qt.questionid = question_rec.questionid
                AND qt.answer = qt.testanswer
                AND r.testdate = p_testdate;
                EXIT WHEN question_cur%NOTFOUND;
                
                SELECT question INTO v_question
                FROM questionbank
                WHERE questionid = question_rec.questionid;
                
                DBMS_OUTPUT.PUT_LINE(question_rec.questionid || '  ' || v_question);
                SORT_ANSWER_3(question_rec.questionid,p_subcode,p_testdate,v_all_score_pre_question);
                DBMS_OUTPUT.PUT_LINE('User correct answer: ' || v_true_question 
                                     || ' / ' || v_all_score_pre_question);
                v_false_question := v_all_score_pre_question - v_true_question;
                v_true_subject := v_true_subject + v_true_question;
                v_true_chapter := v_true_chapter + v_true_question;
                v_all_score_pre_chapter := v_all_score_pre_chapter + v_all_score_pre_question;
                v_all_score_subject := v_all_score_subject + v_all_score_pre_question;
                DBMS_OUTPUT.PUT_LINE('User uncorrect answer: ' || v_false_question 
                                     || ' / ' || v_all_score_pre_question);
                DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('Score of Chapter: ' || i || ' '
                                 || v_true_chapter || ' / ' || v_all_score_pre_chapter);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            CLOSE question_cur;
        END LOOP;
            DBMS_OUTPUT.PUT_LINE('Score of subject ' || p_subcode
                                 || ': ' || v_true_subject 
                                 || ' / ' || v_all_score_subject || ' in date: '
                                 || p_testdate);
    END ANALYZE_TEST;
    
    PROCEDURE SORT_ANSWER_1 (p_questionid questionbank.question%TYPE,
                             p_testdate registration.testdate%TYPE,
                             p_subcode registration.subjectcode%TYPE) IS    
        answer_unsort answer_table_test := answer_table_test();
        answer_sort answer_table_test := answer_table_test();
        v_count NUMBER := 0;
        v_count_answer NUMBER := 0;
        v_count_answer_choose NUMBER := 0;
        v_ans NUMBER := 0;
        v_test NUMBER := 0;
        v_count_loop NUMBER := 0;
        v_answer_check NUMBER := 0;
        
        CURSOR other_regis_cur IS
        SELECT qt.questionid,qt.testanswer,qt.answer,qt.a_id,qt.b_id,qt.c_id,qt.d_id,r.subjectcode,r.testdate
        FROM registration r
        JOIN questiontest qt ON r.registrationno = qt.registrationno
        JOIN questionbank qb ON qt.questionid = qb.questionid;
        
        CURSOR answer_cur IS
            SELECT answerid,answer
            FROM answerbank
            WHERE questionid =  p_questionid;
        answer_rec answer_cur%ROWTYPE;
    BEGIN    
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
                IF other_regis_rec.testdate = p_testdate AND
                   other_regis_rec.subjectcode = p_subcode THEN
                        CASE
                            WHEN other_regis_rec.testanswer = 'A' THEN
                                v_test := other_regis_rec.a_id;
                            WHEN other_regis_rec.testanswer = 'B' THEN
                                v_test := other_regis_rec.b_id;
                            WHEN other_regis_rec.testanswer = 'C' THEN
                                v_test := other_regis_rec.c_id;
                            ELSE
                                v_test := other_regis_rec.d_id;
                        END CASE;
                    IF v_test = answer_unsort(i).id_value THEN 
                        v_count_answer_choose := v_count_answer_choose + 1;
                    END IF;
                    ----Store count select answer----
                    answer_unsort(i) := answer_obj_test(answer_unsort(i).id_value,
                                                        answer_unsort(i).text_value,
                                                        v_count_answer_choose);
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
            IF v_answer_check = 1 THEN
                DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : '
                                     || answer_sort(i).count_value || ' is answer correct.');
            ELSIF v_answer_check = 2 THEN
                DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : '
                                     || answer_sort(i).count_value || ' is answer uncorrect.');
            END IF;
        END LOOP;
        CLOSE answer_cur;
    END SORT_ANSWER_1;
    
    PROCEDURE SORT_ANSWER_2 (p_questionid IN questionbank.question%TYPE,
                             p_subcode IN registration.subjectcode%TYPE,
                             p_count_all_answer OUT NUMBER) IS    
        answer_unsort answer_table_test := answer_table_test();
        answer_sort answer_table_test := answer_table_test();
        v_count NUMBER := 0;
        v_count_answer NUMBER := 0;
        v_count_answer_choose NUMBER := 0;
        v_ans NUMBER := 0;
        v_test NUMBER := 0;
        v_count_loop NUMBER := 0;
        v_answer_check NUMBER := 0;
        
        CURSOR other_regis_cur IS
            SELECT qt.questionid,qt.testanswer,qt.answer,qt.a_id,qt.b_id,qt.c_id,qt.d_id,r.subjectcode,r.testdate
            FROM registration r
            JOIN questiontest qt ON r.registrationno = qt.registrationno
            JOIN questionbank qb ON qt.questionid = qb.questionid;
        
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
                IF other_regis_rec.subjectcode = p_subcode THEN
                        CASE
                            WHEN other_regis_rec.testanswer = 'A' THEN
                                v_test := other_regis_rec.a_id;
                            WHEN other_regis_rec.testanswer = 'B' THEN
                                v_test := other_regis_rec.b_id;
                            WHEN other_regis_rec.testanswer = 'C' THEN
                                v_test := other_regis_rec.c_id;
                            ELSE
                                v_test := other_regis_rec.d_id;
                        END CASE;
                    IF v_test = answer_unsort(i).id_value THEN 
                        v_count_answer_choose := v_count_answer_choose + 1;
                        p_count_all_answer := p_count_all_answer + 1;
                    END IF;
                    ----Store count select answer----
                    answer_unsort(i) := answer_obj_test(answer_unsort(i).id_value,
                                                        answer_unsort(i).text_value,
                                                        v_count_answer_choose);
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
            IF v_answer_check = 1 THEN
                DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : '
                                     || answer_sort(i).count_value || ' is answer correct.');
            ELSIF v_answer_check = 2 THEN
                DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : '
                                     || answer_sort(i).count_value || ' is answer uncorrect.');
            END IF;
        END LOOP;
    CLOSE answer_cur;
    END SORT_ANSWER_2;

    PROCEDURE SORT_ANSWER_3 (p_questionid IN questionbank.question%TYPE,
                             p_subcode IN registration.subjectcode%TYPE,
                             p_testdate IN registration.testdate%TYPE,
                             p_count_all_answer OUT NUMBER) IS    
        answer_unsort answer_table_test := answer_table_test();
        answer_sort answer_table_test := answer_table_test();
        v_count NUMBER := 0;
        v_count_answer NUMBER := 0;
        v_count_answer_choose NUMBER := 0;
        v_ans NUMBER := 0;
        v_test NUMBER := 0;
        v_count_loop NUMBER := 0;
        v_answer_check NUMBER := 0;
        
        CURSOR other_regis_cur IS
            SELECT qt.questionid,qt.testanswer,qt.answer,qt.a_id,qt.b_id,qt.c_id,qt.d_id,r.subjectcode,r.testdate
            FROM registration r
            JOIN questiontest qt ON r.registrationno = qt.registrationno
            JOIN questionbank qb ON qt.questionid = qb.questionid;
        
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
                IF other_regis_rec.subjectcode = p_subcode 
                AND other_regis_rec.testdate = p_testdate THEN
                        CASE
                            WHEN other_regis_rec.testanswer = 'A' THEN
                                v_test := other_regis_rec.a_id;
                            WHEN other_regis_rec.testanswer = 'B' THEN
                                v_test := other_regis_rec.b_id;
                            WHEN other_regis_rec.testanswer = 'C' THEN
                                v_test := other_regis_rec.c_id;
                            ELSE
                                v_test := other_regis_rec.d_id;
                        END CASE;
                    IF v_test = answer_unsort(i).id_value THEN 
                        v_count_answer_choose := v_count_answer_choose + 1;
                        p_count_all_answer := p_count_all_answer + 1;
                    END IF;
                    ----Store count select answer----
                    answer_unsort(i) := answer_obj_test(answer_unsort(i).id_value,
                                                        answer_unsort(i).text_value,
                                                        v_count_answer_choose);
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
            IF v_answer_check = 1 THEN
                DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : '
                                     || answer_sort(i).count_value || ' is answer correct.');
            ELSIF v_answer_check = 2 THEN
                DBMS_OUTPUT.PUT_LINE(answer_sort(i).text_value || ' : '
                                     || answer_sort(i).count_value || ' is answer uncorrect.');
            END IF;
        END LOOP;
    CLOSE answer_cur;
    END SORT_ANSWER_3;
END PACKAGE_ANALYSIS;

EXECUTE PACKAGE_ANALYSIS.ANALYZE_TEST(300001);

EXECUTE PACKAGE_ANALYSIS.ANALYZE_TEST('INT102');

EXECUTE PACKAGE_ANALYSIS.ANALYZE_TEST('INT102','02 Á.¤. 2019');