package com.example.qnuquiz.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.mapper.TeacherMapper;
import com.example.qnuquiz.repository.TeacherRepository;
import com.example.qnuquiz.service.TeacherService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class TeacherServiceImpl implements TeacherService {

    private final TeacherMapper teacherMapper;
    private final TeacherRepository teacherRepository;

    @Override
    public List<TeacherDto> getAllTeachers() {
        return teacherMapper.toDtoList(teacherRepository.findAll());
    }

}
