package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.entity.QuestionOptions;

@Repository
public interface QuestionOptionRepository extends JpaRepository<QuestionOptions, Long> {

}
