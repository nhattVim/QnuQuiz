package com.example.qnuquiz.dto.faqs;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class FaqDto {
    private long id;
    private String question;
    private String answer;
    private Timestamp createdAt;
}
