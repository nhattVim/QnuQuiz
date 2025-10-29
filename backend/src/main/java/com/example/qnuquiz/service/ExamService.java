package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Questions;

public interface ExamService {
    ExamAttempts startExam(Long examId, Long studentId);
    ExamAnswers submitAnswer(Long attemptId, Long questionId, Long optionId);
    ExamAttempts finishExam(Long attemptId);
    ExamAnswers submitEssay(Long attemptId, Long questionId, String answerText);
    List<Questions> getQuestionsForExam(Long examId);
}
