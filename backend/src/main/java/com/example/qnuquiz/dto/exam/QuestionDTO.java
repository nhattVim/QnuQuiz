package com.example.qnuquiz.dto.exam;

import java.math.BigDecimal;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

//DTO cho Question
@Data 
@Builder 
@NoArgsConstructor 
@AllArgsConstructor

public class QuestionDTO {
 private long id;
 private String content;
 private String type; // "ESSAY" hoặc "MULTIPLE_CHOICE"
 private BigDecimal points;
 private List<QuestionOptionDTO> options;
}
