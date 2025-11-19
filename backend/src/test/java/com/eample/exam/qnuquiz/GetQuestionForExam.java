package com.eample.exam.qnuquiz;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.qnuquiz.dto.exam.QuestionDTO;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.mapper.ExamMapper;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.service.impl.ExamServiceImpl;

@ExtendWith(MockitoExtension.class)
public class GetQuestionForExam {

    @Mock private ExamRepository examRepository;
    @Mock private QuestionRepository questionRepository;
    @Mock private ExamMapper examMapper;

    @InjectMocks private ExamServiceImpl examService;

    @Test
    void testGetQuestionsForExam_nonRandom_returnsOrderedList() {
        Long examId = 1L;

        Exams exam = new Exams();
        exam.setId(examId);
        exam.setRandom(false);

        Questions q1 = new Questions(); q1.setId(101L);
        Questions q2 = new Questions(); q2.setId(102L);

        QuestionDTO dto1 = QuestionDTO.builder().id(101L).content("Q1").build();
        QuestionDTO dto2 = QuestionDTO.builder().id(102L).content("Q2").build();

        List<Questions> questions = List.of(q1, q2);

        when(examRepository.findById(examId)).thenReturn(Optional.of(exam));
        when(questionRepository.findByExamsId(examId)).thenReturn(questions);
        when(examMapper.toQuestionDTO(q1)).thenReturn(dto1);
        when(examMapper.toQuestionDTO(q2)).thenReturn(dto2);

        List<QuestionDTO> result = examService.getQuestionsForExam(examId);

        assertEquals(2, result.size());
        assertEquals(101L, result.get(0).getId());
        assertEquals(102L, result.get(1).getId());
    }

    @Test
    void testGetQuestionsForExam_random_returnsShuffledLimitedList() {
        Long examId = 2L;

        Exams exam = new Exams();
        exam.setId(examId);
        exam.setRandom(true);

        List<Questions> questions = new ArrayList<>();
        for (int i = 0; i < 50; i++) {
            Questions q = new Questions();
            q.setId(i);
            questions.add(q);
            when(examMapper.toQuestionDTO(q)).thenReturn(
                QuestionDTO.builder().id(q.getId()).content("Q" + q.getId()).build()
            );
        }

        when(examRepository.findById(examId)).thenReturn(Optional.of(exam));
        when(questionRepository.findByExamsId(examId)).thenReturn(questions);

        List<QuestionDTO> result = examService.getQuestionsForExam(examId);

        assertEquals(30, result.size()); // giới hạn 30 câu hỏi
    }

    @Test
    void testGetQuestionsForExam_examNotFound_throwsException() {
        Long examId = 99L;
        when(examRepository.findById(examId)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> {
            examService.getQuestionsForExam(examId);
        });

        assertEquals("Exam not found", ex.getMessage());
    }


}
