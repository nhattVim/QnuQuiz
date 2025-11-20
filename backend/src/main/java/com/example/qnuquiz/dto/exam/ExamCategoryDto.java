package com.example.qnuquiz.dto.exam;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamCategoryDto {
    private Long id;
    private String name;
    private Long totalExams;
}
