package com.example.qnuquiz.dto.user;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserLoginDto {

    private String username;
    private String password;
}
