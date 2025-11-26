package com.example.qnuquiz.dto.exam;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamDto {

    private long id;
    private String title;
    private String description;
    private Timestamp startTime;
    private Timestamp endTime;
    private boolean random;
    private Integer durationMinutes;
    private String status;
    private boolean hasUnfinishedAttempt;
    @Builder.Default
    private boolean hasAttempt = false; // Có attempt (làm qua) hay chưa
}
