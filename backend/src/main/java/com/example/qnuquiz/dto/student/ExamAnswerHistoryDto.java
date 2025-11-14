package com.example.qnuquiz.dto.student;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamAnswerHistoryDto {
    private Long questionId;
    private String questionContent;
    private Long selectedOptionId;
    private String selectedOptionContent;
    private Boolean isCorrect;
    private String answerText; // For text-based answers
}

