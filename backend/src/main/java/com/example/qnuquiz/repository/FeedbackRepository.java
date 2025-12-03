package com.example.qnuquiz.repository;

import java.util.List;
<<<<<<< HEAD
import java.util.Optional;
=======
>>>>>>> 484c1a59854f30e639debb9cd597f466f61ceb1d

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.qnuquiz.entity.Feedbacks;

public interface FeedbackRepository extends JpaRepository<Feedbacks, Long> {

<<<<<<< HEAD
	List<Feedbacks> findByQuestions_Id(Long questionId);

	List<Feedbacks> findByQuestions_IdAndStatus(Long questionId, String status);

	List<Feedbacks> findByExams_Id(Long examId);

	List<Feedbacks> findByExams_IdAndStatus(Long examId, String status);

	Optional<Feedbacks> findByUsersByUserIdAndQuestions( com.example.qnuquiz.entity.Users user,
			com.example.qnuquiz.entity.Questions question);

	Optional<Feedbacks> findByUsersByUserIdAndExams( com.example.qnuquiz.entity.Users user,
			com.example.qnuquiz.entity.Exams exam);
=======
    @Query("SELECT f FROM Feedbacks f WHERE f.questions.id IN :questionIds ORDER BY f.createdAt DESC")
    List<Feedbacks> findByQuestionIds(@Param("questionIds") List<Long> questionIds);
>>>>>>> 484c1a59854f30e639debb9cd597f466f61ceb1d
}
