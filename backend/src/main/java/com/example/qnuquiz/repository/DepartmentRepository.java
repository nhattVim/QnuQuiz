package com.example.qnuquiz.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Departments;

public interface DepartmentRepository extends JpaRepository<Departments, Long> {

    Optional<Departments> findByName(String name);
}

