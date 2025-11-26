package com.example.qnuquiz.dto.student;

import java.sql.Timestamp;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamHistoryDto {
    private Long attemptId;
    private Long examId;
    private String examTitle;
    private String examDescription;
    private int score;
    private Timestamp completionDate;
    private Long durationMinutes;
    private List<ExamAnswerHistoryDto> answers;
}
