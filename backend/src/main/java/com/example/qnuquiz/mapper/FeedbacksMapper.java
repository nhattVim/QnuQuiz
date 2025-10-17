package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.feedback.FeedbacksDto;
import com.example.qnuquiz.entity.Feedbacks;

@Mapper(componentModel = "spring")
public interface FeedbacksMapper {

    @Mapping(source = "questions.content", target = "questionContent")
    @Mapping(source = "usersByUserId.username", target = "userName")
    @Mapping(source = "usersByReviewedBy.username", target = "reviewedBy")
    FeedbacksDto toDto(Feedbacks feedback);

    List<FeedbacksDto> toDtoList(List<Feedbacks> feedbacks);
}
