package com.example.qnuquiz.dto.teacher;

import java.sql.Timestamp;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeacherNotificationDto {
    
    // Thông báo về bài thi
    private List<ExamAnnouncementDto> examAnnouncements;
    
    // Các vấn đề của lớp
    private List<ClassIssueDto> classIssues;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExamAnnouncementDto {
        private Long id;
        private String title;
        private String content;
        private String target;
        private String className;
        private String departmentName;
        private String authorName;
        
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", timezone = "UTC")
        private Timestamp publishedAt;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClassIssueDto {
        private Long id;
        private String questionContent;
        private Long examId;
        private String examTitle;
        private String studentName;
        private String studentCode;
        private String className;
        private String content;
        private String status;
        
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", timezone = "UTC")
        private Timestamp createdAt;
        
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", timezone = "UTC")
        private Timestamp reviewedAt;
    }
}

