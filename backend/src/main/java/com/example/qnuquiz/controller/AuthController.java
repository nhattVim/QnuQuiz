package com.example.qnuquiz.controller;

import java.util.Map;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.dto.user.UserLoginDto;
import com.example.qnuquiz.dto.user.UserRegisterDto;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authManager;
    private final UserService userService;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody UserLoginDto request) {
        String username = request.getUsername();
        String password = request.getPassword();

        authManager.authenticate(new UsernamePasswordAuthenticationToken(username, password));
        Users user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String token = jwtUtil.generateToken(user.getUsername());

        return Map.of(
                "token", token,
                "user", Map.of(
                        "id", user.getId(),
                        "username", user.getUsername(),
                        "email", user.getEmail(),
                        "role", user.getRole()));
    }

    @PostMapping("/register")
    @CacheEvict(value = "allUsers", allEntries = true)
    public ResponseEntity<UserDto> register(@RequestBody UserRegisterDto dto) {
        return ResponseEntity.ok(userService.register(dto));
    }
}
