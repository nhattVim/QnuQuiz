package com.example.qnuquiz.service;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public interface QuestionService {

    void importQuestionsFromExcel(MultipartFile file) throws IOException;
}
