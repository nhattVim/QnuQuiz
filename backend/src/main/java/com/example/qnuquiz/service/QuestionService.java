package com.example.qnuquiz.service;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

import org.springframework.web.multipart.MultipartFile;

import com.example.qnuquiz.dto.questions.QuestionDTO;

public interface QuestionService {

    void importQuestionsFromExcel(MultipartFile file, UUID userId, Long examId) throws IOException;

    List<QuestionDTO> getAllQuestionsInExam(Long examId);

    QuestionDTO createQuestion(QuestionDTO dto, Long examId);

    QuestionDTO updateQuestion(QuestionDTO dto);

    void deleteQuestion(List<Long> ids);
}
