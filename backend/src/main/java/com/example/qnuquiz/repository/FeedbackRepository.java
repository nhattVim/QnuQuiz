package com.example.qnuquiz.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Feedbacks;

public interface FeedbackRepository extends JpaRepository<Feedbacks, Long> {

	List<Feedbacks> findByQuestions_Id(Long questionId);

	List<Feedbacks> findByQuestions_IdAndStatus(Long questionId, String status);

	List<Feedbacks> findByExams_Id(Long examId);

	List<Feedbacks> findByExams_IdAndStatus(Long examId, String status);

	Optional<Feedbacks> findByUsersByUserIdAndQuestions( com.example.qnuquiz.entity.Users user,
			com.example.qnuquiz.entity.Questions question);

	Optional<Feedbacks> findByUsersByUserIdAndExams( com.example.qnuquiz.entity.Users user,
			com.example.qnuquiz.entity.Exams exam);
}
