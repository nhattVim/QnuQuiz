package com.example.qnuquiz.dto.feedback;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FeedbackTemplateDto {

    private String code;
    private String label;
    private String content;
}
