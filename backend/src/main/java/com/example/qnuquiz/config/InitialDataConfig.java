package com.example.qnuquiz.config;

import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.UserRepository;

import lombok.extern.slf4j.Slf4j;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.sql.Timestamp;

@Slf4j
@Configuration
public class InitialDataConfig {

    @Bean
    public CommandLineRunner createInitialAdmin(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            if (!userRepository.existsByUsername("admin")) {

                Users admin = new Users();
                admin.setUsername("admin");
                admin.setPasswordHash(passwordEncoder.encode("admin123"));
                admin.setFullName("Super Admin");
                admin.setEmail("admin@qnuquiz.com");
                admin.setRole("ADMIN");
                admin.setStatus("ACTIVE");
                admin.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                admin.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

                userRepository.save(admin);
                log.info(">>> Admin created");
            }
        };
    }
}
