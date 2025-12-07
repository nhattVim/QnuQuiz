package com.example.qnuquiz.dto.questions;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuestionOptionDto {

    private long id;
    private String content;
    private Integer position;
    private boolean correct;
}
