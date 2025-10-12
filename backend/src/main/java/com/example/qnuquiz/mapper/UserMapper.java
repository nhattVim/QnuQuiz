package com.example.qnuquiz.mapper;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.example.qnuquiz.dto.UserDto;
import com.example.qnuquiz.entity.Users;

@Component
public class UserMapper {

    public UserDto toDto(Users user) {
        if (user == null) {
            return null;
        }

        // UserDto dto = new UserDto();
        // dto.setId(user.getId());
        // dto.setUsername(user.getUsername());
        // dto.setFullName(user.getFullName());
        // dto.setEmail(user.getEmail());
        // dto.setRole(user.getRole());
        // dto.setStatus(user.getStatus());
        // dto.setCreatedAt(user.getCreatedAt());
        // dto.setUpdatedAt(user.getUpdatedAt());
        // return dto;

        return UserDto.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole())
                .status(user.getStatus())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }

    public Users toEntity(UserDto dto) {
        if (dto == null) {
            return null;
        }

        Users user = new Users();
        user.setId(dto.getId());
        user.setUsername(dto.getUsername());
        user.setFullName(dto.getFullName());
        user.setEmail(dto.getEmail());
        user.setRole(dto.getRole());
        user.setStatus(dto.getStatus());
        user.setCreatedAt(dto.getCreatedAt());
        user.setUpdatedAt(dto.getUpdatedAt());
        user.setRole(dto.getRole());
        user.setStatus(dto.getStatus());
        user.setCreatedAt(dto.getCreatedAt());
        user.setUpdatedAt(dto.getUpdatedAt());
        // Không map passwordHash vì sẽ được xử lý riêng
        // Không map các quan hệ (questionses, teacherses, v.v.)
        return user;
    }

    public List<UserDto> toDtoList(List<Users> users) {
        if (users == null || users.isEmpty()) {
            // Trả về danh sách rỗng để tránh NullPointerException
            return Collections.emptyList();
        }
        return users.stream().map(this::toDto).collect(Collectors.toList());
    }
}
