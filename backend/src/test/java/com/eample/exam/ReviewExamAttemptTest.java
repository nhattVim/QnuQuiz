package com.eample.exam;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.qnuquiz.dto.exam.ExamAnswerReviewDTO;
import com.example.qnuquiz.dto.exam.ExamReviewDTO;
import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.mapper.ExamMapper;
import com.example.qnuquiz.repository.ExamAnswerRepository;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.service.impl.ExamServiceImpl;

@ExtendWith(MockitoExtension.class)
class ReviewExamAttemptTest {

    @Mock private ExamAttemptRepository examAttemptRepository;
    @Mock private ExamAnswerRepository examAnswerRepository;
    @Mock private ExamMapper examMapper;

    @InjectMocks private ExamServiceImpl examService;

    @Test
    void testReviewExamAttempt_success() {
        Long attemptId = 1L;

        // Mock ExamAttempts
        Exams exam = new Exams();
        exam.setTitle("Math Final");

        ExamAttempts attempt = new ExamAttempts();
        attempt.setId(attemptId);
        attempt.setExams(exam);
        attempt.setScore(BigDecimal.valueOf(8));

        // Mock ExamAnswers
        ExamAnswers answer1 = new ExamAnswers(); answer1.setId(101L);
        ExamAnswers answer2 = new ExamAnswers(); answer2.setId(102L);
        List<ExamAnswers> answers = List.of(answer1, answer2);

        // Mock DTOs
        ExamAnswerReviewDTO dto1 = ExamAnswerReviewDTO.builder()
                .questionId(1L)
                .questionContent("What is 2+2?")
                .type("MULTIPLE_CHOICE")
                .studentAnswer("4")
                .isCorrect(true)
                .build();

        ExamAnswerReviewDTO dto2 = ExamAnswerReviewDTO.builder()
                .questionId(2L)
                .questionContent("Explain gravity.")
                .type("ESSAY")
                .studentAnswer("Gravity pulls objects down.")
                .isCorrect(false)
                .build();

        when(examAttemptRepository.findById(attemptId)).thenReturn(Optional.of(attempt));
        when(examAnswerRepository.findByExamAttempts_Id(attemptId)).thenReturn(answers);
        when(examMapper.toExamAnswerReviewDTO(answer1)).thenReturn(dto1);
        when(examMapper.toExamAnswerReviewDTO(answer2)).thenReturn(dto2);

        // Act
        ExamReviewDTO result = examService.reviewExamAttempt(attemptId);

        // Assert
        assertEquals(attemptId, result.getExamAttemptId());
        assertEquals("Math Final", result.getExamTitle());
        assertEquals(BigDecimal.valueOf(8), result.getScore());
        assertEquals(2, result.getAnswers().size());
        assertEquals("What is 2+2?", result.getAnswers().get(0).getQuestionContent());
        assertEquals("Explain gravity.", result.getAnswers().get(1).getQuestionContent());
    }

    @Test
    void testReviewExamAttempt_notFound_throwsException() {
        Long attemptId = 999L;
        when(examAttemptRepository.findById(attemptId)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> {
            examService.reviewExamAttempt(attemptId);
        });

        assertEquals("Exam attempt not found", ex.getMessage());
    }
}
