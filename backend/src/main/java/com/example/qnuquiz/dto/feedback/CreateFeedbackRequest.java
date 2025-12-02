package com.example.qnuquiz.dto.feedback;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateFeedbackRequest {

    // Có thể là feedback cho câu hỏi hoặc cho bài thi
    private Long questionId;
    private Long examId;

    @NotNull(message = "content is required")
    @Size(min = 5, max = 2000, message = "content length must be between 5 and 2000 characters")
    private String content;

    @NotNull(message = "rating is required")
    @Min(value = 1, message = "rating must be at least 1")
    @Max(value = 5, message = "rating must be at most 5")
    private Integer rating;
}


