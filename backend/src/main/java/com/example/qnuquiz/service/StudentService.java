package com.example.qnuquiz.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.repository.StudentRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class StudentService {

    private final StudentRepository studentRepository;

    public List<Students> getAllStudents() {
        return studentRepository.findAll();
    }
}
