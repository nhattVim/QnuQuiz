package com.example.qnuquiz.service.impl;

import java.util.List;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.dto.student.StudentUpdateDto;
import com.example.qnuquiz.entity.Classes;
import com.example.qnuquiz.entity.Departments;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.StudentMapper;
import com.example.qnuquiz.repository.ClassesRepository;
import com.example.qnuquiz.repository.DepartmentsRepository;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.service.StudentService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class StudentServiceImpl implements StudentService {

    private final StudentMapper studentMapper;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;
    private final ClassesRepository classesRepository;
    private final DepartmentsRepository departmentsRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public List<StudentDto> getAllStudents() {
        return studentMapper.toDtoList(studentRepository.findAll());
    }

    @Override
    @Transactional
    public StudentDto updateStudentProfile(UUID userId, StudentUpdateDto updateDto) {
        // Find user
        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        // Find student record
        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new RuntimeException("Student not found for user id: " + userId));

        // Update user fields
        if (updateDto.getEmail() != null && !updateDto.getEmail().isBlank()) {
            user.setEmail(updateDto.getEmail());
        }
        if (updateDto.getPhoneNumber() != null) {
            user.setPhoneNumber(updateDto.getPhoneNumber());
        }
        if (updateDto.getFullName() != null && !updateDto.getFullName().isBlank()) {
            user.setFullName(updateDto.getFullName());
        }
        if (updateDto.getPassword() != null && !updateDto.getPassword().isBlank()) {
            user.setPasswordHash(passwordEncoder.encode(updateDto.getPassword()));
        }

        // Update student fields
        if (updateDto.getClassId() != null) {
            Classes classes = classesRepository.findById(updateDto.getClassId())
                    .orElseThrow(() -> new RuntimeException("Class not found with id: " + updateDto.getClassId()));
            student.setClasses(classes);
        }
        if (updateDto.getDepartmentId() != null) {
            Departments department = departmentsRepository.findById(updateDto.getDepartmentId())
                    .orElseThrow(() -> new RuntimeException("Department not found with id: " + updateDto.getDepartmentId()));
            student.setDepartments(department);
        }

        // Save entities
        userRepository.save(user);
        studentRepository.save(student);

        return studentMapper.toDto(student);
    }

}
