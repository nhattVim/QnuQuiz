package com.example.qnuquiz.service;

import org.springframework.web.multipart.MultipartFile;

import com.example.qnuquiz.dto.questions.QuestionFullDto;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

public interface QuestionService {

    void importQuestionsFromExcel(MultipartFile file, UUID userId, Long examId) throws IOException;

    List<QuestionFullDto> getAllQuestionsInExam(Long examId);

    QuestionFullDto updateQuestion(QuestionFullDto dto);

    void deleteQuestion(List<Long> ids);
}
