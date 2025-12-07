package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.dto.teacher.TeacherNotificationDto;
import com.example.qnuquiz.service.TeacherService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@EnableMethodSecurity
@RequestMapping("/api/teachers")
public class TeacherController {

    private final TeacherService teacherService;

    @GetMapping
    public ResponseEntity<List<TeacherDto>> getAllTeachers() {
        return ResponseEntity.ok(teacherService.getAllTeachers());
    }

    @GetMapping("/me/notifications")
    @PreAuthorize("hasRole('TEACHER')")
    public ResponseEntity<TeacherNotificationDto> getNotifications() {
        return ResponseEntity.ok(teacherService.getNotificationsForCurrentTeacher());
    }
}
