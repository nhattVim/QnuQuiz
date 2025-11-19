package com.example.qnuquiz.dto.exam;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamCategoryDto {
    private Long id;
    private String name;
    private Timestamp createdAt;
}
