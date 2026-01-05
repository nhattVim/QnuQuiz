package com.example.qnuquiz.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.qnuquiz.entity.Feedbacks;

public interface FeedbackRepository extends JpaRepository<Feedbacks, Long> {
    List<Feedbacks> findByQuestions_Id(Long questionId);

    List<Feedbacks> findByQuestions_IdAndStatus(Long questionId, String status);

    List<Feedbacks> findByExams_Id(Long examId);

    List<Feedbacks> findByExams_IdAndStatus(Long examId, String status);

    Optional<Feedbacks> findByUsersByUserIdAndQuestions(com.example.qnuquiz.entity.Users user,
            com.example.qnuquiz.entity.Questions question);

    Optional<Feedbacks> findByUsersByUserIdAndExams(com.example.qnuquiz.entity.Users user,
            com.example.qnuquiz.entity.Exams exam);

    List<Feedbacks> findByUsersByUserId(com.example.qnuquiz.entity.Users user);

    @Query("SELECT f FROM Feedbacks f WHERE f.questions.id IN :questionIds ORDER BY f.createdAt DESC")
    List<Feedbacks> findByQuestionIds(@Param("questionIds") List<Long> questionIds);

    @Modifying
    @Query("DELETE FROM Feedbacks f WHERE f.exams.id = :examId")
    void deleteByExamId(@Param("examId") Long examId);

    @Modifying
    @Query("DELETE FROM Feedbacks f WHERE f.questions.id IN :questionIds")
    void deleteByQuestionIds(@Param("questionIds") List<Long> questionIds);
}
