package com.example.qnuquiz.dto.analytics;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserAnalyticsDto {
    private long totalUsers;
    private long newUsersThisMonth;
    private long activeUsers;
    private long studentsCount;
    private long teachersCount;
    private long adminCount;
}
