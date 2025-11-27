package com.example.qnuquiz.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
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

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authManager;
    private final UserService userService;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@Valid @RequestBody UserLoginDto request) {
        authManager.authenticate(new UsernamePasswordAuthenticationToken(
                request.getUsername(),
                request.getPassword()));

        Users user = userService.findByUsername(request.getUsername()).orElseThrow(
                () -> new BadCredentialsException("Invalid username or password"));

        String token = jwtUtil.generateToken(user.getUsername());

        Map<String, Object> responseBody = Map.of(
                "token", token,
                "user", Map.of(
                        "id", user.getId(),
                        "username", user.getUsername(),
                        "email", user.getEmail(),
                        "role", user.getRole()));

        return ResponseEntity.ok(responseBody);
    }

    @PostMapping("/register")
    public ResponseEntity<UserDto> register(@Valid @RequestBody UserRegisterDto dto) {
        return ResponseEntity.ok(userService.register(dto));
    }
}
