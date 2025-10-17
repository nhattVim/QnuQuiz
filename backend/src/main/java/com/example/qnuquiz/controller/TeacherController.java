package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.entity.Teachers;
import com.example.qnuquiz.mapper.TeacherMapper;
import com.example.qnuquiz.service.TeacherService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/teachers")
public class TeacherController {

    private final TeacherService teacherService;
    private final TeacherMapper teacherMapper;

    @GetMapping
    public ResponseEntity<List<TeacherDto>> getAllTeachers() {
        List<Teachers> teachers = teacherService.getAllTeachers();
        List<TeacherDto> dtoList = teacherMapper.toDtoList(teachers);
        return ResponseEntity.ok(dtoList);
    }
}
