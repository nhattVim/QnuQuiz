package com.example.qnuquiz.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.entity.Teachers;
import com.example.qnuquiz.repository.TeacherRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TeacherService {

    private final TeacherRepository teacherRepository;

    public List<Teachers> getAllTeachers() {
        return teacherRepository.findAll();
    }
}
