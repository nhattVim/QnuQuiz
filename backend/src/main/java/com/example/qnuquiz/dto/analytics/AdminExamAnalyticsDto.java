package com.example.qnuquiz.dto.analytics;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AdminExamAnalyticsDto {
    private long totalExams;
    private long activeExams;
    private double averageQuestionsPerExam;
    private double averageAttemptsPerExam;
    private double overallAverageScore;
}
