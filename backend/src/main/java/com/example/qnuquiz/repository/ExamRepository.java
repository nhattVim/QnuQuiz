package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.entity.Exams;

@Repository
public interface ExamRepository extends JpaRepository<Exams, Long> {}

