package com.example.qnuquiz.dto.teacher;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TeacherDto {

    private long id;
    private String userId;
    private String username;
    private String fullName;
    private String email;
    private String phoneNumber;
    private Long departmentId;
    private String teacherCode;
    private String title;
}
