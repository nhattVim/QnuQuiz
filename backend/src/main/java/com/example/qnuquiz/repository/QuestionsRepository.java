package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Questions;

public interface QuestionsRepository extends JpaRepository<Questions, Long> {

    
}
