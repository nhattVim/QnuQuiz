package com.example.qnuquiz.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Users;

public interface UserRepository extends JpaRepository<Users, UUID> {

}
