package com.example.qnuquiz.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.entity.ExamQuestions;
import com.example.qnuquiz.entity.QuestionOptions;

@Repository
public interface QuestionOptionsRepository extends JpaRepository<QuestionOptions, Long> {
    List<QuestionOptions> findByQuestions_Id(Long questionId);
}
