package com.example.qnuquiz.dto.questions;

import java.math.BigDecimal;
import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionFullDto {

    private long id;
    private String content;
    private BigDecimal point;
    private List<QuestionOptionDto> options;
}
