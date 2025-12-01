package com.example.qnuquiz.dto.analytics;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentAttemptDto {
    
    private String studentCode;
    private String fullName;
    private String className;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Double durationMinutes;
    private Double score;
    private Boolean submitted;
}
