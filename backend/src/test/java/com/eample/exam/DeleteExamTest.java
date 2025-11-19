package com.eample.exam;

import static org.mockito.Mockito.verify;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.service.impl.ExamServiceImpl;

@ExtendWith(MockitoExtension.class)
public class DeleteExamTest {

    @Mock
    private ExamRepository examRepository;

    @InjectMocks
    private ExamServiceImpl examService;

    @Test
    public void testDeleteExam_success() {
        Long examId = 1L;

        // Act
        examService.deleteExam(examId);

        // Assert
        verify(examRepository).deleteById(examId);
    }
}