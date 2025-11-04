package com.example.qnuquiz.dto.exam;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamCreateDto {

    private long id;
    private String userId;
    private String title;
    private String description;
    private Timestamp startTime;
    private Timestamp endTime;
    private boolean random;
    private Integer durationMinutes;
    private String status;
}
