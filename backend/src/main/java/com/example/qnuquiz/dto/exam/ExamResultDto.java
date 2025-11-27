package com.example.qnuquiz.dto.exam;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamResultDto {

    private int score;
    private long correctCount;
    private long totalQuestions;
}
