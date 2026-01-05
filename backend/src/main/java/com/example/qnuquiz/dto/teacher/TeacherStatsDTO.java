package com.example.qnuquiz.dto.teacher;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TeacherStatsDTO {

    private long teacherId;
    private String teacherCode;
    private String fullName;
    private long totalExams;
    private long totalQuestions;
    private long totalStudents;
    private long totalExamAttempts;
    private double averageScore;
    private long totalFeedbacks;
}
