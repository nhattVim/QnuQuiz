package com.example.qnuquiz.dto.feedback;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FeedbackTemplateDto {

    private String code;    // ví dụ: "GOOD_KNOWLEDGE"
    private String label;   // text hiển thị trên tag
    private String content; // nội dung sẽ điền vào ô Bình luận
}


