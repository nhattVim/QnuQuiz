package com.example.qnuquiz.dto.questions;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionDto {

    private long id;
    private String questionCategories;
    private String userName;
    private String content;
    private String type;
    private String difficulty;
    private Timestamp createdAt;
    private Timestamp updatedAt;
}
