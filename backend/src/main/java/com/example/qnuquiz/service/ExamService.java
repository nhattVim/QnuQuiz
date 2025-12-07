package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamCategoryDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.dto.exam.ExamResultDto;
import com.example.qnuquiz.dto.exam.ExamReviewDTO;
import com.example.qnuquiz.dto.questions.QuestionDTO;

public interface ExamService {

	List<ExamDto> getExamsByUserId(String sort);

	ExamDto createExam(ExamDto dto);

	ExamDto updateExam(ExamDto dto);

	void deleteExam(Long id);

	ExamAttemptDto startExam(Long examId);

	void submitAnswer(Long attemptId, Long questionId, Long optionId);

	ExamResultDto finishExam(Long attemptId);

	void submitEssay(Long attemptId, Long questionId, String answerText);

	List<QuestionDTO> getQuestionsForExam(Long examId);

	ExamReviewDTO reviewExamAttempt(Long attemptId);

	List<ExamDto> getAllExams();

	List<ExamDto> getExamsByCategory(Long categoryId);

	ExamAttemptDto getLatestAttempt(Long examId);

	List<ExamCategoryDto> getAllCategories();

}
