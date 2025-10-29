package com.example.qnuquiz.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.entity.ExamAnswers;

@Repository
public interface ExamAnswerRepository extends JpaRepository<ExamAnswers, Long> {
    List<ExamAnswers> findByExamAttempts_Id(Long attemptId);



}
