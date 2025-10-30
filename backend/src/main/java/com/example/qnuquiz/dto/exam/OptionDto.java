package com.example.qnuquiz.dto.exam;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class OptionDto {
    private Long optionId;
    private String content;
}