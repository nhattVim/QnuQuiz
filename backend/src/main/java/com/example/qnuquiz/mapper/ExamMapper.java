package com.example.qnuquiz.mapper;

import java.math.BigDecimal;
import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.AfterMapping;
import org.mapstruct.MappingTarget;

import com.example.qnuquiz.dto.exam.AnswerResultDto;
import com.example.qnuquiz.dto.exam.ExamAnswerReviewDTO;
import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.dto.exam.QuestionDTO;
import com.example.qnuquiz.dto.exam.QuestionExamDto;
import com.example.qnuquiz.dto.exam.QuestionOptionDTO;
import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;

@Mapper(componentModel = "spring")
public interface ExamMapper {

	@Mapping(target = "submit", ignore = true)
	ExamAttemptDto toDto(ExamAttempts attempt);

	QuestionExamDto toQuestionDto(Questions q, List<QuestionOptions> options, String studentAnswer);

	// Khi xem kết quả
	AnswerResultDto toAnswerResultDto(Questions q, ExamAnswers answer, List<QuestionOptions> options,
			BigDecimal points);

	ExamDto toDto(Exams entity);

	List<ExamDto> toListDto(List<Exams> entity);

	QuestionDTO toQuestionDTO(Questions entity);

	@Mapping(target = "questionId", ignore = true)
	@Mapping(target = "questionContent", ignore = true)
	@Mapping(target = "type", ignore = true)
	@Mapping(target = "studentAnswer", ignore = true)
	@Mapping(target = "options", ignore = true)
	@Mapping(target = "correct", source = "isCorrect")
	ExamAnswerReviewDTO toExamAnswerReviewDTO(ExamAnswers entity);

	@Mapping(target = "createdAt", ignore = true)
	@Mapping(target = "examAttemptses", ignore = true)
	@Mapping(target = "leaderboards", ignore = true)
	@Mapping(target = "updatedAt", ignore = true)
	@Mapping(target = "users", ignore = true)
	@Mapping(target = "questionses", ignore = true)
	@Mapping(target = "examCategories", ignore = true)
	Exams toEntity(ExamDto dto);

	List<ExamDto> toDtoList(List<Exams> exams);

default String safe(Object o) {
    return o == null ? null : o.toString();
}

@AfterMapping
default void mapDetails(ExamAnswers entity, @MappingTarget ExamAnswerReviewDTO dto) {
    // Lấy question
    var q = entity.getQuestions();
    dto.setQuestionId(q.getId());
    dto.setQuestionContent(q.getContent());
    dto.setType(q.getType());

    // Lấy studentAnswer
    if (entity.getQuestionOptions() != null) {
        // user chọn theo option
        dto.setStudentAnswer(String.valueOf(entity.getQuestionOptions().getId()));
    } else {
        // dạng text
        dto.setStudentAnswer(entity.getAnswerText());
    }

    // Lấy toàn bộ options của câu hỏi
    if (q.getQuestionOptionses() != null) {
        List<QuestionOptionDTO> optionDTOs = q.getQuestionOptionses()
            .stream()
            .map(opt -> new QuestionOptionDTO(
                opt.getId(),
                opt.getContent(),
								opt.getPosition(),
								opt.getCorrect()
            ))
            .toList();

        dto.setOptions(optionDTOs);
    }
}
}
