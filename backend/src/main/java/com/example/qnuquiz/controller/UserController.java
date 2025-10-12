package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.UserDto;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.UserMapper;
import com.example.qnuquiz.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final UserMapper userMapper;

    @PostMapping
    public ResponseEntity<UserDto> register(@RequestBody UserDto dto) {
        Users user = userMapper.toEntity(dto);
        user.setStatus("ACTIVE");
        user.setRole("USER");
        user.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
        user.setUpdatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
        user.setPasswordHash("temp_hash"); // tạm thời, thực tế bạn sẽ mã hóa password

        Users saved = userService.register(user);
        return ResponseEntity.ok(userMapper.toDto(saved));
    }

    @GetMapping
    public ResponseEntity<List<UserDto>> getAllUsers() {
        // return ResponseEntity.ok(userMapper.toDtoList(userService.getAllUsers()));
        List<Users> users = userService.getAllUsers();
        List<UserDto> dtoList = userMapper.toDtoList(users);
        return ResponseEntity.ok(dtoList);
    }
}
