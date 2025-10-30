package com.example.qnuquiz.dto.exam;

import java.util.List;

import lombok.Builder;
import lombok.Data;
@Data @Builder
public class QuestionExamDto { // dùng khi làm bài
    private Long questionId;
    private String content;
    private String type;
    private List<OptionDto> options;
    private String studentAnswer; // optionId hoặc answerText
}
