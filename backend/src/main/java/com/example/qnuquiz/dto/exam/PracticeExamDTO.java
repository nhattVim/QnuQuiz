package com.example.qnuquiz.dto.exam;

import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder

public class PracticeExamDTO {
    private String title; // ví dụ: "Practice Test - Java Basics"
    private Long categoryId;
    private List<QuestionDTO> questions;
}
