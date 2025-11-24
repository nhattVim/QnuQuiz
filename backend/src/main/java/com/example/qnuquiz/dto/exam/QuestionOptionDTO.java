package com.example.qnuquiz.dto.exam;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class QuestionOptionDTO {
    private long id;
    private String content;
    private Integer position;
    private boolean correct;
}
