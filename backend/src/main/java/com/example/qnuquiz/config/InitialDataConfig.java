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
    public CommandLineRunner createInitialUsers(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            if (adminPassword == null || adminPassword.isBlank() || adminUsername == null || adminUsername.isBlank()) {
                log.warn(">>> Admin username or password isn't set. Skipping user creation for security reasons.");
                return;
            }

            if (!userRepository.existsByUsername(adminUsername)) {
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
            } else {
                log.info(">>> Account with username '{}' already exists. Skipping creation.", adminUsername);
            }

            String teacherUsername = "teacher";
            if (!userRepository.existsByUsername(teacherUsername)) {
                Users teacher = new Users();
                teacher.setUsername(teacherUsername);
                teacher.setPasswordHash(passwordEncoder.encode("123456"));
                teacher.setFullName("Default Teacher");
                teacher.setEmail("teacher@qnuquiz.com");
                teacher.setRole("TEACHER");
                teacher.setStatus("ACTIVE");
                teacher.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                teacher.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
                userRepository.save(teacher);
                log.info(">>> Default teacher user '{}' created successfully.", teacherUsername);
            } else {
                log.info(">>> Account with username '{}' already exists. Skipping creation.", teacherUsername);
            }

            String studentUsername = "student";
            if (!userRepository.existsByUsername(studentUsername)) {
                Users student = new Users();
                student.setUsername(studentUsername);
                student.setPasswordHash(passwordEncoder.encode("123456"));
                student.setFullName("Default Student");
                student.setEmail("student@qnuquiz.com");
                student.setRole("STUDENT");
                student.setStatus("ACTIVE");
                student.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                student.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
                userRepository.save(student);
                log.info(">>> Default student user '{}' created successfully.", studentUsername);
            } else {
                log.info(">>> Account with username '{}' already exists. Skipping creation.", studentUsername);
            }
        };
    }
}
