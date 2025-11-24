package com.example.qnuquiz.dto.analytics;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RankingDto {

    private String username;
    private BigDecimal score;
    private String fullName;
    private String avatarUrl;
}
