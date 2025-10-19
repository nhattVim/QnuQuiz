package com.example.qnuquiz.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.mapper.StudentMapper;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.service.StudentService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class StudentServiceImpl implements StudentService {

    private final StudentMapper studentMapper;
    private final StudentRepository studentRepository;

    @Override
    public List<StudentDto> getAllStudents() {
        return studentMapper.toDtoList(studentRepository.findAll());
    }

}
