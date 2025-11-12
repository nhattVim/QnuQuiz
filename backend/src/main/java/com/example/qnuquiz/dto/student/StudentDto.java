package com.example.qnuquiz.dto.student;

import java.math.BigDecimal;
import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class StudentDto {

    private long id;
    private Long classId;
    private String className;
    private String userName;
    private String fullName;
    private String email;
    private String phoneNumber;
    private Long departmentId;
    private String departmentName;
    private BigDecimal gpa;
    private Timestamp createdAt;
}
