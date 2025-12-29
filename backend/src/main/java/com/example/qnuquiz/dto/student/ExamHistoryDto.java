package com.example.qnuquiz.dto.student;

import java.sql.Timestamp;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

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
    
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", timezone = "UTC")
    private Timestamp completionDate;
    
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", timezone = "UTC")
    private Timestamp startTime;
    
    private Long durationMinutes;
    private Integer examDurationMinutes; // Tổng thời gian của bài thi
    private List<ExamAnswerHistoryDto> answers;
}
