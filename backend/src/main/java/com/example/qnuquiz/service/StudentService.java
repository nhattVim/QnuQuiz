package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.student.ExamHistoryDto;
import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.dto.student.StudentProfileUpdateRequest;

public interface StudentService {

    List<StudentDto> getAllStudents();

    StudentDto updateCurrentStudentProfile(StudentProfileUpdateRequest request);

    List<ExamHistoryDto> getExamHistory();
}