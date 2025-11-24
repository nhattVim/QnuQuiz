package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.ExamCategories;

public interface ExamCategoryRepository extends JpaRepository<ExamCategories, Long> {
}
