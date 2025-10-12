package com.example.qnuquiz.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public Users register(Users user) {
        return userRepository.save(user);
    }

    public List<Users> getAllUsers() {
        return userRepository.findAll();
    }
}
