package com.example.qnuquiz.dto.analytics;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AdminQuestionAnalyticsDto {
    private long totalQuestions;
    private long multipleChoiceQuestions;
    private long trueFalseQuestions; // Assuming other types
    private double averageOptionsPerQuestion;
    private double averageUsageInExams;
}
