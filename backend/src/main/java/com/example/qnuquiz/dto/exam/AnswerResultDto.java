package com.example.qnuquiz.dto.exam;

import java.math.BigDecimal;

import lombok.Builder;
import lombok.Data;
@Data @Builder
public class AnswerResultDto { // dùng khi xem kết quả
    private Long questionId;
    private String questionContent;
    private String selectedOptionContent;
    private String answerText;
    private String correctOptionContent;
    private Boolean isCorrect;
    private BigDecimal points;
}
///hhhhhh