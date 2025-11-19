package com.eample.exam;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamResultDto;
import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.ExamAnswerRepository;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.QuestionOptionsRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.service.impl.ExamServiceImpl;

@ExtendWith(MockitoExtension.class)
public class ActionExamTest {

    @Mock private ExamRepository examRepository;
    @Mock private UserRepository userRepository;
    @Mock private StudentRepository studentRepository;
    @Mock private ExamAttemptRepository attemptRepo;
    
    @Mock private QuestionOptionsRepository optionRepo;
    @Mock private ExamAnswerRepository answerRepo;

    @Mock private QuestionRepository questionRepo;


    @InjectMocks private ExamServiceImpl examService;

    @Test
    void testStartExam_success() {
        Long examId = 1L;
        UUID userId = UUID.randomUUID();

        Exams exam = new Exams(); exam.setId(examId);
        Users user = new Users(); user.setId(userId);
        Students student = new Students(); student.setId(100L);

        ExamAttempts savedAttempt = new ExamAttempts();
        savedAttempt.setId(10L);
        savedAttempt.setExams(exam);
        savedAttempt.setStartTime(new Timestamp(System.currentTimeMillis()));
        savedAttempt.setSubmitted(false);

        when(examRepository.findById(examId)).thenReturn(Optional.of(exam));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(studentRepository.findByUsers(user)).thenReturn(Optional.of(student));
        when(attemptRepo.save(any(ExamAttempts.class))).thenReturn(savedAttempt);

        ExamAttemptDto result = examService.startExam(examId, userId);

        assertEquals(10L, result.getId());
        assertEquals(examId, result.getExamId());
        assertEquals(false, result.isSubmit());
        verify(attemptRepo).save(any(ExamAttempts.class));
    }
    

@Test
void testSubmitAnswer_createNewAnswer() {
    Long attemptId = 1L, questionId = 2L, optionId = 3L;

    ExamAttempts attempt = new ExamAttempts(); attempt.setId(attemptId);
    Questions question = new Questions(); question.setId(questionId);
    QuestionOptions option = new QuestionOptions();
    option.setId(optionId); option.setCorrect(true); option.setQuestions(question);

    when(attemptRepo.findById(attemptId)).thenReturn(Optional.of(attempt));
    when(optionRepo.findById(optionId)).thenReturn(Optional.of(option));
    when(answerRepo.findByExamAttemptsIdAndQuestionsId(attemptId, questionId)).thenReturn(Optional.empty());

    examService.submitAnswer(attemptId, questionId, optionId);

    verify(answerRepo).save(any(ExamAnswers.class));
}

@Test
void testSubmitEssay_success() {
    Long attemptId = 1L, questionId = 2L;
    String answerText = "This is my essay";

    ExamAttempts attempt = new ExamAttempts(); attempt.setId(attemptId);
    Questions question = new Questions(); question.setId(questionId);

    when(attemptRepo.findById(attemptId)).thenReturn(Optional.of(attempt));
    when(questionRepo.findById(questionId)).thenReturn(Optional.of(question));

    examService.submitEssay(attemptId, questionId, answerText);

    verify(answerRepo).save(any(ExamAnswers.class));
}
@Test
void testFinishExam_success() {
    Long attemptId = 1L;

    ExamAttempts attempt = new ExamAttempts(); attempt.setId(attemptId);

    ExamAnswers a1 = new ExamAnswers(); a1.setIsCorrect(true);
    ExamAnswers a2 = new ExamAnswers(); a2.setIsCorrect(false);
    ExamAnswers a3 = new ExamAnswers(); a3.setIsCorrect(true);

    List<ExamAnswers> answers = List.of(a1, a2, a3);

    when(attemptRepo.findById(attemptId)).thenReturn(Optional.of(attempt));
    when(answerRepo.findByExamAttempts_Id(attemptId)).thenReturn(answers);
    when(attemptRepo.save(any(ExamAttempts.class))).thenReturn(attempt);

    ExamResultDto result = examService.finishExam(attemptId);

    assertEquals(2, result.getCorrectCount());
    assertEquals(3, result.getTotalQuestions());
    assertEquals(BigDecimal.valueOf(2), result.getScore());
    verify(attemptRepo).save(attempt);
}


}
