package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.exam.AnswerResultDto;
import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.QuestionExamDto;
import com.example.qnuquiz.entity.ExamAttempts;

public interface ExamService {
	ExamAttemptDto startExam(Long examId, Long studentId);
	void submitAnswer(Long attemptId, Long questionId, Long optionId);
    ExamAttempts finishExam(Long attemptId);
    void submitEssay(Long attemptId, Long questionId, String answerText);
    List<QuestionExamDto> getQuestionsForExam(Long examId, Long attemptId); // khi làm bài
    List<AnswerResultDto> getResultForAttempt(Long attemptId);  
}
	