package com.example.qnuquiz.dto.user;

import lombok.Data;

@Data
public class UserCreateDto {

    private String username;
    private String password;
    private String fullName;
    private String email;
}
