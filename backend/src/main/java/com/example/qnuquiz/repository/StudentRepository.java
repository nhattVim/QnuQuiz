package com.example.qnuquiz.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Users;

public interface StudentRepository extends JpaRepository<Students, Long> {
	Optional<Students> findByUsers(Users users);


}
