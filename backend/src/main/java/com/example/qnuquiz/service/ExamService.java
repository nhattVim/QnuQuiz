package com.example.qnuquiz.service;

import java.util.List;
import java.util.UUID;

import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.dto.exam.ExamResultDto;
import com.example.qnuquiz.dto.exam.ExamReviewDTO;
import com.example.qnuquiz.dto.exam.PracticeExamDTO;
import com.example.qnuquiz.dto.exam.QuestionDTO;

public interface ExamService {

	List<ExamDto> getExamsByUserId(UUID userId, String sort);

	ExamDto createExam(ExamDto dto, UUID userId);

	ExamDto updateExam(ExamDto dto, UUID userId);

	void deleteExam(Long id);

	ExamAttemptDto startExam(Long examId, UUID userId);

	void submitAnswer(Long attemptId, Long questionId, Long optionId);

	ExamResultDto finishExam(Long attemptId);

	void submitEssay(Long attemptId, Long questionId, String answerText);

	List<QuestionDTO> getQuestionsForExam(Long examId, int limit);

	ExamReviewDTO reviewExamAttempt(Long attemptId);
	
	List<ExamDto> getAllExams();

}
