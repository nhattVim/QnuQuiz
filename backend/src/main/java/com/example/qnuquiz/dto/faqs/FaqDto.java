package com.example.qnuquiz.dto.faqs;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FaqDto {

    private long id;
    private String question;
    private String answer;
    private Timestamp createdAt;
}
