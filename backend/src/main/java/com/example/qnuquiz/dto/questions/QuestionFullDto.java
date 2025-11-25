package com.example.qnuquiz.dto.questions;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuestionFullDto {

    private long id;
    private String content;
    private List<QuestionOptionDto> options;
}
