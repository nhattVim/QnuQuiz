package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.mapper.StudentMapper;
import com.example.qnuquiz.service.StudentService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/students")
public class StudenController {

    private final StudentService studentService;
    private final StudentMapper studentMapper;

    @GetMapping
    public ResponseEntity<List<StudentDto>> getAllStudents() {
        List<Students> students = studentService.getAllStudents();
        List<StudentDto> dtoList = studentMapper.toDtoList(students);
        return ResponseEntity.ok(dtoList);
    }
}
