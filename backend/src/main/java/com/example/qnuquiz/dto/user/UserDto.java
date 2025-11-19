package com.example.qnuquiz.dto.user;

import java.sql.Timestamp;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class UserDto {

    private UUID id;
    private String username;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String role;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
}
