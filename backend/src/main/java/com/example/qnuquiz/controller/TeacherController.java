package com.example.qnuquiz.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.dto.teacher.TeacherNotificationDto;
import com.example.qnuquiz.dto.user.ChangePasswordRequest;
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

    @PutMapping("/me/profile")
    @PreAuthorize("hasRole('TEACHER')")
    public ResponseEntity<TeacherDto> updateCurrentTeacherProfile(
            @RequestBody TeacherDto request) {
        return ResponseEntity.ok(teacherService.updateCurrentTeacherProfile(request));
    }

    @PutMapping("/me/password")
    @PreAuthorize("hasRole('TEACHER')")
    public ResponseEntity<Map<String, String>> changePassword(
            @RequestBody ChangePasswordRequest request) {
        teacherService.changePassword(request);
        return ResponseEntity.ok(Map.of("message", "Đổi mật khẩu thành công"));
    }
}
