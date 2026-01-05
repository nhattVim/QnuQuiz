package com.example.qnuquiz.service;

import java.util.List;
import java.util.Optional;

import com.example.qnuquiz.dto.user.ChangePasswordRequest;
import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.dto.user.UserRegisterDto;
import com.example.qnuquiz.entity.Users;

public interface UserService {

    UserDto register(UserRegisterDto dto);

    List<UserDto> getAllUsers();

    Optional<Users> findByUsername(String username);

    Object getCurrentUserProfile();

    UserDto createUser(UserDto userDto);

    UserDto updateUser(String id, UserDto userDto);

    UserDto updateCurrentUserProfile(UserDto userDto);

    void deleteUser(String id);

    void updatePasswordByEmail(String email, String newPassword);
    
    void changePassword(ChangePasswordRequest request);
}
