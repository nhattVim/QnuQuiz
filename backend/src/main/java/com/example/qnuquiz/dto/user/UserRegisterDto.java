package com.example.qnuquiz.dto.user;

import lombok.Data;

@Data
public class UserRegisterDto {

    private String username;
    private String password;
    private String fullName;
    private String email;
    private String role;
}
