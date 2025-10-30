package com.example.qnuquiz.mapper;

import java.math.BigDecimal;
import java.util.List;

import org.mapstruct.Mapper;

import com.example.qnuquiz.dto.exam.AnswerResultDto;
import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.QuestionExamDto;
import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;

@Mapper(componentModel = "spring")
public interface ExamMapper {
	ExamAttemptDto toDto(ExamAttempts dto);
    QuestionExamDto toQuestionDto(Questions q, List<QuestionOptions> options, String studentAnswer);

   // Khi xem kết quả
    AnswerResultDto toAnswerResultDto(Questions q, ExamAnswers answer, List<QuestionOptions> options, BigDecimal points);




}
