package com.example.qnuquiz.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Teachers;
import com.example.qnuquiz.entity.Users;

public interface TeacherRepository extends JpaRepository<Teachers, Long> {

    Optional<Teachers> findByUsers(Users user);

}
