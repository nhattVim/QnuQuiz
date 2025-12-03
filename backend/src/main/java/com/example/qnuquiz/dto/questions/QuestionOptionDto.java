package com.example.qnuquiz.dto.questions;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionOptionDto {
  
    private long id;
    private String content;
    private boolean correct;
}
