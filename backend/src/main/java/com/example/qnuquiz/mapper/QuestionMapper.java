
package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.questions.QuestionDTO;
import com.example.qnuquiz.dto.questions.QuestionImportDto;
import com.example.qnuquiz.entity.Questions;

@Mapper(componentModel = "spring")
public interface QuestionMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "examAnswerses", ignore = true)
    @Mapping(target = "feedbackses", ignore = true)
    @Mapping(target = "questionOptionses", ignore = true)
    @Mapping(target = "type", ignore = true)
    @Mapping(target = "users", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "exams", ignore = true)
    @Mapping(target = "ordering", ignore = true)
    Questions toEntity(QuestionImportDto dto);

    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "examAnswerses", ignore = true)
    @Mapping(target = "feedbackses", ignore = true)
    @Mapping(target = "questionOptionses", ignore = true)
    @Mapping(target = "type", ignore = true)
    @Mapping(target = "users", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "exams", ignore = true)
    @Mapping(target = "ordering", ignore = true)
    Questions toEntity(QuestionDTO dto);

    @Mapping(target = "options", ignore = true)
    QuestionDTO toQuestionDTO(Questions entity);

    List<QuestionDTO> toQuestionDtoList(List<Questions> questions);
}
