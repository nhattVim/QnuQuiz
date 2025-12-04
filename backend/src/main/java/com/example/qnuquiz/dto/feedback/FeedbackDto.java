package com.example.qnuquiz.dto.feedback;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FeedbackDto {

    private Long id;
    private String questionContent;
    private String userName;
    private String reviewedBy;
    private String content;
    private Integer rating;
    private String status;
    private Timestamp createdAt;
    private Timestamp reviewedAt;
}
