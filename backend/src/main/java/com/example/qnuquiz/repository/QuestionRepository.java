package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Questions;

public interface QuestionRepository extends JpaRepository<Questions, Long> {

}
