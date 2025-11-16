package com.example.qnuquiz.dto.student;

import java.sql.Timestamp;
import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamHistoryDto {
    private Long attemptId;
    private Long examId;
    private String examTitle;
    private String examDescription;
    private java.math.BigDecimal score;
    private Timestamp completionDate;
    private Long durationMinutes;
    private List<ExamAnswerHistoryDto> answers;
}

