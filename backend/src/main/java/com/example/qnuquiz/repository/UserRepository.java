package com.example.qnuquiz.repository;

import com.example.qnuquiz.entity.Users;
import org.springframework.data.jpa.repository.JpaRepository;

import java.sql.Timestamp;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<Users, UUID> {

    boolean existsByUsername(String username);

    Optional<Users> findByUsername(String username);

    Optional<Users> findById(UUID id);

    long countByCreatedAtAfter(Timestamp timestamp);

    long countByRole(String role);
}
