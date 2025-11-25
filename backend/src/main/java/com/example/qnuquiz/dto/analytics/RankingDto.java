package com.example.qnuquiz.dto.analytics;

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
    private Long score;
    private String fullName;
    private String avatarUrl;
}
