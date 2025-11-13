package com.example.qnuquiz.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Questions;

public interface QuestionRepository extends JpaRepository<Questions, Long> {

    List<Questions> findByExamsId(Long id);

    List<Questions> findByQuestionCategoriesId(Long categoryId);

}
