package com.example.qnuquiz.controller;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;

import com.example.qnuquiz.config.SecurityConfig;
import com.example.qnuquiz.exception.GlobalExceptionHandler;

@WebMvcTest
@AutoConfigureMockMvc
@Import({GlobalExceptionHandler.class, SecurityConfig.class}) // import cấu hình bảo mật
public abstract class BaseTest {

    @Autowired
    protected MockMvc mockMvc;

    @BeforeEach
    void setupSecurityContext() {
        // giả lập user đăng nhập với role STUDENT
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        Authentication auth = new UsernamePasswordAuthenticationToken(
                "student", "password",
                List.of(new SimpleGrantedAuthority("ROLE_STUDENT"))
        );
        context.setAuthentication(auth);
        SecurityContextHolder.setContext(context);
    }
}
