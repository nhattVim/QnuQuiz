package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.user.UserRegisterDto;
import com.example.qnuquiz.dto.user.UserDto;

public interface UserService {

    UserDto register(UserRegisterDto dto);

    List<UserDto> getAllUsers();
}
