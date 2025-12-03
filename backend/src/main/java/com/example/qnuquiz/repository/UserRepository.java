package com.example.qnuquiz.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Users;

public interface UserRepository extends JpaRepository<Users, UUID> {

    boolean existsByUsername(String username);

    Optional<Users> findByUsername(String username);

    Optional<Users> findById(UUID id);
}
