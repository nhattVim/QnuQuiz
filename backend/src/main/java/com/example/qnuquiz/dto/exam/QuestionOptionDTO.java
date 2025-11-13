package com.example.qnuquiz.dto.exam;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionOptionDTO {
    private long id;
    private String content;
    private Integer position;

}
