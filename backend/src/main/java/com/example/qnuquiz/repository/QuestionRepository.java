package com.example.qnuquiz.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.qnuquiz.entity.Questions;

public interface QuestionRepository extends JpaRepository<Questions, Long> {

    List<Questions> findByExamsId(Long id);

    @Query("SELECT COUNT(q) FROM Questions q WHERE CAST(q.type AS string) = :type")
    long countByType(@Param("type") String type);
}
