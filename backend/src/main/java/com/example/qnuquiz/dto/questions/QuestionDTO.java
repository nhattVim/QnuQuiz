package com.example.qnuquiz.dto.questions;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

//DTO cho Question
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuestionDTO {
    private long id;
    private String content;
    private String type; // "ESSAY" hoặc "MULTIPLE_CHOICE"
    private List<QuestionOptionDto> options;
}
