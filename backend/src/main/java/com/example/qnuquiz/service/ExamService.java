package com.example.qnuquiz.service;

import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamCreateDto;
import com.example.qnuquiz.entity.ExamAttempts;

public interface ExamService {

	ExamCreateDto createExam(ExamCreateDto dto);

	ExamAttemptDto startExam(Long examId, Long studentId);

	void submitAnswer(Long attemptId, Long questionId, Long optionId);

	ExamAttempts finishExam(Long attemptId);

	void submitEssay(Long attemptId, Long questionId, String answerText);

	// List<QuestionExamDto> getQuestionsForExam(Long examId, Long attemptId);

	// List<AnswerResultDto> getResultForAttempt(Long attemptId);
}
