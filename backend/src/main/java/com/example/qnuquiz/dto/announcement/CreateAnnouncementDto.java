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
    private String target; // ALL, DEPARTMENT, CLASS
    private Long classId; // ID của lớp (chỉ cần khi target = CLASS)
    private Long departmentId; // ID của khoa (chỉ cần khi target = DEPARTMENT)
}

