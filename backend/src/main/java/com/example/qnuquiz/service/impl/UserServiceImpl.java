package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.dto.user.UserRegisterDto;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Teachers;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.StudentMapper;
import com.example.qnuquiz.mapper.TeacherMapper;
import com.example.qnuquiz.mapper.UserMapper;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.repository.TeacherRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.UserService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final StudentMapper studentMapper;
    private final TeacherMapper teacherMapper;

    @Override
    @CacheEvict(value = "allUsers", allEntries = true)
    public UserDto register(UserRegisterDto dto) {
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        Users user = userMapper.toEntity(dto);
        user.setStatus("ACTIVE");
        user.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        if (dto.getRole() != null && !dto.getRole().isBlank()) {
            if (dto.getRole().equalsIgnoreCase("ADMIN")) {
                throw new RuntimeException("Cannot assign ADMIN role through register API");
            }
            user.setRole(dto.getRole().toUpperCase());
        } else {
            user.setRole("STUDENT");
        }

        Users saved = userRepository.save(user);
        return userMapper.toDto(saved);
    }

    @Override
    @Cacheable("allUsers")
    public List<UserDto> getAllUsers() {
        return userMapper.toDtoList(userRepository.findAll());
    }

    @Override
    public Optional<Users> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Override
    @CacheEvict(value = "allUsers", allEntries = true)
    public UserDto createUser(UserDto userDto) {
        if (userRepository.existsByUsername(userDto.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        Users user = userMapper.toEntity(userDto);
        user.setStatus("ACTIVE");
        user.setPasswordHash(passwordEncoder.encode("password")); // Default password
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        Users saved = userRepository.save(user);
        return userMapper.toDto(saved);
    }

    @Override
    @CacheEvict(value = "allUsers", allEntries = true)
    public UserDto updateUser(String id, UserDto userDto) {
        Users existingUser = userRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new RuntimeException("User not found"));

        existingUser.setFullName(userDto.getFullName());
        existingUser.setEmail(userDto.getEmail());
        existingUser.setPhoneNumber(userDto.getPhoneNumber());
        existingUser.setRole(userDto.getRole().toUpperCase());
        existingUser.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        Users updated = userRepository.save(existingUser);
        return userMapper.toDto(updated);
    }

    @Override
    @CacheEvict(value = "allUsers", allEntries = true)
    public void deleteUser(String id) {
        userRepository.deleteById(UUID.fromString(id));
    }

    @Override
    public Object getCurrentUserProfile() {
        UUID currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw new RuntimeException("User not authenticated");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String role = user.getRole();

        if ("STUDENT".equalsIgnoreCase(role)) {
            Students student = studentRepository.findByUsers(user)
                    .orElseThrow(() -> new RuntimeException("Student profile not found for user"));
            return studentMapper.toDto(student);
        } else if ("TEACHER".equalsIgnoreCase(role)) {
            Teachers teacher = teacherRepository.findByUsers(user)
                    .orElseThrow(() -> new RuntimeException("Teacher profile not found for user"));
            return teacherMapper.toDto(teacher);
        } else {
            return userMapper.toDto(user);
        }
    }

    @Override
    @CacheEvict(value = "allUsers", allEntries = true)
    public void updatePasswordByEmail(String email, String newPassword) {
        Users user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
        
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
        userRepository.save(user);
    }
}
