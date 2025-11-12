package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.dto.student.StudentProfileUpdateRequest;
import com.example.qnuquiz.entity.Classes;
import com.example.qnuquiz.entity.Departments;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.StudentMapper;
import com.example.qnuquiz.repository.ClassesRepository;
import com.example.qnuquiz.repository.DepartmentRepository;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.StudentService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class StudentServiceImpl implements StudentService {

    private final StudentMapper studentMapper;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;
    private final DepartmentRepository departmentRepository;
    private final ClassesRepository classesRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public List<StudentDto> getAllStudents() {
        return studentMapper.toDtoList(studentRepository.findAll());
    }

    @Override
    @Transactional
    public StudentDto updateCurrentStudentProfile(StudentProfileUpdateRequest request) {
        if (request == null) {
            throw new RuntimeException("Dữ liệu cập nhật không hợp lệ");
        }

        if (!StringUtils.hasText(request.getFullName()) || !StringUtils.hasText(request.getEmail())
                || !StringUtils.hasText(request.getPhoneNumber())) {
            throw new RuntimeException("Vui lòng điền đầy đủ thông tin họ tên, email và số điện thoại");
        }

        if (request.getDepartmentId() == null || request.getClassId() == null) {
            throw new RuntimeException("Vui lòng chọn khoa và lớp");
        }

        if (StringUtils.hasText(request.getNewPassword()) && request.getNewPassword().length() < 6) {
            throw new RuntimeException("Mật khẩu phải có ít nhất 6 ký tự");
        }

        UUID currentUserId = SecurityUtils.getCurrentUserId();

        if (currentUserId == null) {
            throw new RuntimeException("Không xác định được người dùng hiện tại");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        if (!"STUDENT".equalsIgnoreCase(user.getRole())) {
            throw new RuntimeException("Chỉ sinh viên mới có thể cập nhật thông tin cá nhân");
        }

        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin sinh viên"));

        Departments department = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy khoa"));

        Classes classes = classesRepository.findById(request.getClassId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp"));

        if (classes.getDepartments() != null && classes.getDepartments().getId() != department.getId()) {
            throw new RuntimeException("Lớp không thuộc khoa đã chọn");
        }

        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        if (StringUtils.hasText(request.getNewPassword())) {
            user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        }

        student.setDepartments(department);
        student.setClasses(classes);

        studentRepository.save(student);
        userRepository.save(user);

        return studentMapper.toDto(student);
    }

}
