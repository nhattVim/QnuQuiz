package com.example.qnuquiz.dto.questions;

import lombok.Data;

@Data
public class QuestionImportDto {

    private String content;
    private String option1;
    private String option2;
    private String option3;
    private String option4;
    private Integer correctAnswer;
}
