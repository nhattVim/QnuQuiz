package com.example.qnuquiz.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import com.example.qnuquiz.entity.QuestionOptions;

public interface QuestionOptionsRepository extends JpaRepository<QuestionOptions, Long> {

    List<QuestionOptions> findByQuestions_Id(Long questionId);

    void deleteAllByQuestions_IdIn(List<Long> ids);
}
