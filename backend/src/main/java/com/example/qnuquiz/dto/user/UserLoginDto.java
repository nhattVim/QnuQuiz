package com.example.qnuquiz.dto.user;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UserLoginDto {

    @NotNull
    private String username;

    @NotNull
    private String password;
}
