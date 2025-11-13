package com.example.qnuquiz.dto.exam;

import java.math.BigDecimal;
import java.util.List;

import lombok.Builder;
import lombok.Data;
@Data
@Builder
public class ExamReviewDTO {

	private long examAttemptId;
    private String examTitle;
    private BigDecimal score;
    private List<ExamAnswerReviewDTO> answers;
}

