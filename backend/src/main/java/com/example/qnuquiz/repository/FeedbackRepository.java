package com.example.qnuquiz.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.qnuquiz.entity.Feedbacks;

public interface FeedbackRepository extends JpaRepository<Feedbacks, Long> {

    @Query("SELECT f FROM Feedbacks f WHERE f.questions.id IN :questionIds ORDER BY f.createdAt DESC")
    List<Feedbacks> findByQuestionIds(@Param("questionIds") List<Long> questionIds);
}
