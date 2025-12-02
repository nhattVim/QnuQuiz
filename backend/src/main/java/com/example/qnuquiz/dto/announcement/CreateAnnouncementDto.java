package com.example.qnuquiz.dto.announcement;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateAnnouncementDto {
    private String title;
    private String content;
    private Long classId; // ID của lớp cần đăng thông báo
}

