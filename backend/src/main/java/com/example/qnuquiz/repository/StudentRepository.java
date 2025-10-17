package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Students;

public interface StudentRepository extends JpaRepository<Students, Long> {

}
