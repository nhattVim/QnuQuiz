package com.example.qnuquiz.dto.questions;

import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionFullDto {

    private long id;
    private String content;
    private List<QuestionOptionDto> options;
}
