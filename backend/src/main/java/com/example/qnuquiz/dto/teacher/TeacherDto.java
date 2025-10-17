package com.example.qnuquiz.dto.teacher;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TeacherDto {

    private long id;
    private String userName;
    private String departmentName;
    private String teacherCode;
    private String title;
    private Timestamp createdAt;
}
