package com.example.qnuquiz.dto.student;

import java.math.BigDecimal;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class StudentDto {

    private long id;
    private String username;
    private String fullName;
    private String email;
    private String phoneNumber;
    private Long classId;
    private Long departmentId;
    private BigDecimal gpa;
}
