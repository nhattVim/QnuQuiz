package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.dto.teacher.TeacherNotificationDto;
import com.example.qnuquiz.dto.user.ChangePasswordRequest;

public interface TeacherService {

    List<TeacherDto> getAllTeachers();
    
    TeacherNotificationDto getNotificationsForCurrentTeacher();
    
    TeacherDto updateCurrentTeacherProfile(TeacherDto request);
    
    void changePassword(ChangePasswordRequest request);
}
