package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.util.List;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.user.UserCreateDto;
import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.UserMapper;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.service.UserService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    @Override
    public UserDto register(UserCreateDto dto) {
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        Users user = userMapper.toEntity(dto);
        user.setStatus("ACTIVE");
        user.setRole("USER");
        user.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        Users saved = userRepository.save(user);
        return userMapper.toDto(saved);
    }

    @Override
    public List<UserDto> getAllUsers() {
        return userMapper.toDtoList(userRepository.findAll());
    }

}
