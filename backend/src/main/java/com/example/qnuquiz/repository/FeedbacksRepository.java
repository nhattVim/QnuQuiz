package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Feedbacks;

public interface FeedbacksRepository extends JpaRepository<Feedbacks, Long> {

}
