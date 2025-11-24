package com.example.qnuquiz.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.entity.Exams;

@Repository
public interface ExamRepository extends JpaRepository<Exams, Long> {

    List<Exams> findByUsers_Id(UUID userId);
    List<Exams> findByExamCategories_Id(Long categoryId);
    Long countByExamCategories_Id(Long categoryId);
}
