package com.example.qnuquiz.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.entity.ExamAnswers;

@Repository
public interface ExamAnswerRepository extends JpaRepository<ExamAnswers, Long> {
    List<ExamAnswers> findByExamAttempts_Id(Long attemptId);
    Optional<ExamAnswers> findByExamAttemptsIdAndQuestionsId(Long attemptId, Long questionId);
    
    @Modifying
    @Query("UPDATE ExamAnswers e SET e.questionOptions = NULL WHERE e.questionOptions.id IN :optionIds")
    void setQuestionOptionsToNullByOptionIds(@Param("optionIds") List<Long> optionIds);
    
    @Modifying
    @Query("DELETE FROM ExamAnswers e WHERE e.questions.id IN :questionIds")
    void deleteByQuestionIds(@Param("questionIds") List<Long> questionIds);

    @Modifying
    @Query("DELETE FROM ExamAnswers e WHERE e.examAttempts.id IN :attemptIds")
    void deleteByAttemptIds(@Param("attemptIds") List<Long> attemptIds);
}
