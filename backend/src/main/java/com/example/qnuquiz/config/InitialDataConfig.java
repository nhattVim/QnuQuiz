package com.example.qnuquiz.config;

import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.UserRepository;

import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.sql.Timestamp;

@Slf4j
@Configuration
public class InitialDataConfig {

    @Value("${admin.password:#{null}}")
    private String adminPassword;

    @Value("${admin.username:#{null}}")
    private String adminUsername;

    @Bean
    public CommandLineRunner createInitialAdmin(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            if (adminPassword == null || adminPassword.isBlank() || adminUsername == null || adminUsername.isBlank()) {
                log.warn(">>> Admin username or password is not set. Skipping admin creation for security reasons.");
                return;
            }

            if (userRepository.existsByUsername(adminUsername)) {
                log.info(">>> Account with username '{}' already exists. Skipping creation.", adminUsername);
                return;
            }

            Users admin = new Users();
            admin.setUsername(adminUsername);
            admin.setPasswordHash(passwordEncoder.encode(adminPassword));
            admin.setFullName("Super Admin");
            admin.setEmail("admin@qnuquiz.com");
            admin.setRole("ADMIN");
            admin.setStatus("ACTIVE");
            admin.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            admin.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

            userRepository.save(admin);
            log.info(">>> Admin user '{}' created successfully.", adminUsername);
        };
    }
}
