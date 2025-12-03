package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.dto.teacher.TeacherNotificationDto;

public interface TeacherService {

    List<TeacherDto> getAllTeachers();
    
    TeacherNotificationDto getNotificationsForCurrentTeacher();
}
