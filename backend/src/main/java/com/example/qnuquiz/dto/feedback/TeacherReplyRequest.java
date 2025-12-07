package com.example.qnuquiz.dto.feedback;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TeacherReplyRequest {

    @NotBlank(message = "reply is required")
    private String reply;

    private String status;
}

