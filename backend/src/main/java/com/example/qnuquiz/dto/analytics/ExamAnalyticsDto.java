package com.example.qnuquiz.dto.analytics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamAnalyticsDto {
    
    private Long examId;
    private String examTitle;
    private Long totalAttempts;
    private Long totalSubmitted;
    private Double avgScore;
    private Double maxScore;
    private Double minScore;
}
