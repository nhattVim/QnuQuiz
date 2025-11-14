package com.example.qnuquiz.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Classes;

public interface ClassesRepository extends JpaRepository<Classes, Long> {
    Optional<Classes> findById(Long id);
}

