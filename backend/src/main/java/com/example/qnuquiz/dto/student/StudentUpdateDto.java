package com.example.qnuquiz.dto.student;

import lombok.Data;

@Data
public class StudentUpdateDto {
    private String email;
    private String phoneNumber;
    private String fullName;
    private Long departmentId;
    private Long classId;
    private String password;
}
