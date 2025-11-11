package com.example.qnuquiz.dto.exam;

import java.math.BigDecimal;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamResultDto {
    private BigDecimal score;     // Số điểm
    private long correctCount;    // Số câu đúng
    private long totalQuestions;  // Tổng số câu
}
