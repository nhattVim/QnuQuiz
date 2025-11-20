package com.example.qnuquiz.dto.user;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UserRegisterDto {

    private String username;
    private String password;
    private String fullName;
    private String phoneNumber;
    private String email;
    private String role;
}
