package com.example.qnuquiz.dto.analytics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuestionAnalyticsDto {
    
    private String questionContent;
    private Long totalAnswers;
    private Long correctCount;
    private Long wrongCount;
    private Double correctRate;
}
