package com.example.qnuquiz.mapper;

import java.math.BigDecimal;
import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.exam.AnswerResultDto;
import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamCreateDto;
import com.example.qnuquiz.dto.exam.QuestionExamDto;
import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;

@Mapper(componentModel = "spring")
public interface ExamMapper {

	@Mapping(target = "submit", ignore = true)
	ExamAttemptDto toDto(ExamAttempts dto);

	QuestionExamDto toQuestionDto(Questions q, List<QuestionOptions> options, String studentAnswer);

	// Khi xem kết quả
	AnswerResultDto toAnswerResultDto(Questions q, ExamAnswers answer, List<QuestionOptions> options,
			BigDecimal points);

	@Mapping(source = "users.id", target = "userId")
	ExamCreateDto toCreateDto(Exams entity);

	@Mapping(target = "createdAt", ignore = true)
	@Mapping(target = "examAttemptses", ignore = true)
	@Mapping(target = "leaderboards", ignore = true)
	@Mapping(target = "updatedAt", ignore = true)
	@Mapping(target = "users", ignore = true)
	@Mapping(target = "questionses", ignore = true)
	Exams toEntity(ExamCreateDto dto);
}
