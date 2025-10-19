package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.user.UserCreateDto;
import com.example.qnuquiz.dto.user.UserDto;

public interface UserService {

    UserDto register(UserCreateDto dto);

    List<UserDto> getAllUsers();
}
