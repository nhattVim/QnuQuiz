package com.example.qnuquiz.dto.questions;

import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionExportDto {

    private String question;
    private List<String> options;
    private String correctAnswer;
}
