package com.example.qnuquiz.dto.exam;

import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamAnswerReviewDTO {
    private long questionId;
    private String questionContent;
    private String type;
    private String studentAnswer; // text hoặc optionId
    private List<QuestionOptionDTO> options; // hiển thị cả đáp án
    private boolean correct;
}

