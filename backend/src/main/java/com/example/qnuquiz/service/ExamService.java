package com.example.qnuquiz.service;

import java.util.List;
import java.util.UUID;

import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.entity.ExamAttempts;

public interface ExamService {

	List<ExamDto> getExamsByUserId(UUID userId, String sort);

	ExamDto createExam(ExamDto dto, UUID userId);

	ExamDto updateExam(ExamDto dto, UUID userId);

	ExamAttemptDto startExam(Long examId, Long studentId);

	void submitAnswer(Long attemptId, Long questionId, Long optionId);

	ExamAttempts finishExam(Long attemptId);

	void submitEssay(Long attemptId, Long questionId, String answerText);

	// List<QuestionExamDto> getQuestionsForExam(Long examId, Long attemptId);

	// List<AnswerResultDto> getResultForAttempt(Long attemptId);
}
