package com.example.qnuquiz.dto.analytics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScoreDistributionDto {
    
    private String title;
    private Long excellentCount;
    private Long goodCount;
    private Long averageCount;
    private Long failCount;
}
