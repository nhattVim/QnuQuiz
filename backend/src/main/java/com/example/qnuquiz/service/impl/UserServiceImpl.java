package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.user.UserRegisterDto;
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
}
