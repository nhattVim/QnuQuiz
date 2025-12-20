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

import com.example.qnuquiz.dto.user.ForgotPasswordDto;
import com.example.qnuquiz.dto.user.ResetPasswordDto;
import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.dto.user.UserLoginDto;
import com.example.qnuquiz.dto.user.UserRegisterDto;
import com.example.qnuquiz.dto.user.VerifyResetCodeDto;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.EmailService;
import com.example.qnuquiz.service.PasswordResetService;
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
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final PasswordResetService passwordResetService;

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

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@Valid @RequestBody ForgotPasswordDto dto) {
        // Check if email exists
        Users user = userRepository.findByEmail(dto.getEmail())
                .orElse(null);

        if (user == null) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Email chưa được đăng ký trong hệ thống"));
        }

        // Generate and store reset code
        String code = passwordResetService.generateAndStoreResetCode(dto.getEmail());

        // Send email with reset code
        emailService.sendPasswordResetCode(dto.getEmail(), code);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Mã xác thực đã được gửi đến email của bạn"));
    }

    @PostMapping("/verify-reset-code")
    public ResponseEntity<Map<String, Object>> verifyResetCode(@Valid @RequestBody VerifyResetCodeDto dto) {
        boolean isValid = passwordResetService.verifyResetCode(dto.getEmail(), dto.getCode());

        if (!isValid) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Mã xác thực không đúng hoặc đã hết hạn"));
        }

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Mã xác thực hợp lệ"));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, Object>> resetPassword(@Valid @RequestBody ResetPasswordDto dto) {
        // Validate password match
        if (!dto.getNewPassword().equals(dto.getConfirmPassword())) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Mật khẩu xác nhận không khớp"));
        }

        // Verify code
        boolean isValid = passwordResetService.verifyResetCode(dto.getEmail(), dto.getCode());
        if (!isValid) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Mã xác thực không đúng hoặc đã hết hạn"));
        }

        // Reset password
        passwordResetService.resetPassword(dto.getEmail(), dto.getCode());
        userService.updatePasswordByEmail(dto.getEmail(), dto.getNewPassword());

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Đặt lại mật khẩu thành công"));
    }
}
