package com.example.qnuquiz.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Questions;

@Repository
public interface ExamAttemptRepository extends JpaRepository<ExamAttempts, Long> {
	List<ExamAttempts> findByExamsId(Long id);
	List<ExamAttempts> findByStudentsIdAndSubmittedTrueOrderByEndTimeDesc(Long studentId);
}


