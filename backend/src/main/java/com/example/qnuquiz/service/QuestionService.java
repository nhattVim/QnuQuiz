package com.example.qnuquiz.service;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.UUID;

public interface QuestionService {

    void importQuestionsFromExcel(MultipartFile file, UUID userId, Long examId) throws IOException;
}
