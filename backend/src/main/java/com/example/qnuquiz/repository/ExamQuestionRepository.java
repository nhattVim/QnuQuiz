package com.example.qnuquiz.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.entity.ExamQuestions;
import com.example.qnuquiz.entity.ExamQuestionsId;

@Repository
public interface ExamQuestionRepository extends JpaRepository<ExamQuestions, ExamQuestionsId> {
    List<ExamQuestions> findByExams_IdOrderByOrderingAsc(Long examId);
}
