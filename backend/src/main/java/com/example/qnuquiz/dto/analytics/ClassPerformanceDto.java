package com.example.qnuquiz.dto.analytics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClassPerformanceDto {
    
    private String className;
    private Long studentCount;
    private Double avgScorePerClass;
}
