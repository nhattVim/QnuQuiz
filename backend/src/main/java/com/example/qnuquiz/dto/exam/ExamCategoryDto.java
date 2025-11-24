package com.example.qnuquiz.dto.exam;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamCategoryDto {
    private Long id;
    private String name;
    private Long totalExams;
}
