package com.example.qnuquiz.dto.student;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamAnswerHistoryDto {
    private Long questionId;
    private String questionContent;
    private Boolean isCorrect;
    private String answerText;
    private Long selectedOptionId;
    private String selectedOptionContent;
}

