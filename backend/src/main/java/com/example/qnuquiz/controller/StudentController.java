package com.example.qnuquiz.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.dto.student.StudentUpdateDto;
import com.example.qnuquiz.service.StudentService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/students")
public class StudentController {

    private final StudentService studentService;

    @GetMapping
    public ResponseEntity<List<StudentDto>> getAllStudents() {
        return ResponseEntity.ok(studentService.getAllStudents());
    }

    @PutMapping("/{userId}")
    public ResponseEntity<StudentDto> updateStudentProfile(
            @PathVariable UUID userId,
            @RequestBody StudentUpdateDto updateDto) {
        return ResponseEntity.ok(studentService.updateStudentProfile(userId, updateDto));
    }
}
