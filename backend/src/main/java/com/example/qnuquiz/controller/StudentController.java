package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.student.ExamHistoryDto;
import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.dto.student.StudentProfileUpdateRequest;
import com.example.qnuquiz.service.StudentService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@EnableMethodSecurity
@RequestMapping("/api/students")
public class StudentController {

    private final StudentService studentService;

    @GetMapping
    public ResponseEntity<List<StudentDto>> getAllStudents() {
        return ResponseEntity.ok(studentService.getAllStudents());
    }

    @PutMapping("/me/profile")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<StudentDto> updateCurrentStudentProfile(
            @RequestBody StudentProfileUpdateRequest request) {
        return ResponseEntity.ok(studentService.updateCurrentStudentProfile(request));
    }

    @GetMapping("/me/exam-history")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<List<ExamHistoryDto>> getExamHistory() {
        return ResponseEntity.ok(studentService.getExamHistory());
    }
}
