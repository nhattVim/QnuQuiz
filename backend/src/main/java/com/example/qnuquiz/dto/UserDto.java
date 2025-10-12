package com.example.qnuquiz.dto;

import java.sql.Timestamp;
import java.util.UUID;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserDto {

    private UUID id;
    private String username;
    private String fullName;
    private String email;
    private String role;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
}
