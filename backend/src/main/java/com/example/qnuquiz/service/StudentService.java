package com.example.qnuquiz.service;

import java.util.List;
import java.util.UUID;

import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.dto.student.StudentUpdateDto;

public interface StudentService {

    List<StudentDto> getAllStudents();

    StudentDto updateStudentProfile(UUID userId, StudentUpdateDto updateDto);
}
