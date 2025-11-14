package com.example.qnuquiz.dto.student;

import lombok.Data;

@Data
public class StudentProfileUpdateRequest {

    private String fullName;
    private String email;
    private String phoneNumber;
    private Long departmentId;
    private Long classId;
    private String newPassword;
}

