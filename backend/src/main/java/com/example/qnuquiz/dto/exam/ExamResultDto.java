package com.example.qnuquiz.dto.exam;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamResultDto {

    private int score;
    private long correctCount;
    private long totalQuestions;
}
