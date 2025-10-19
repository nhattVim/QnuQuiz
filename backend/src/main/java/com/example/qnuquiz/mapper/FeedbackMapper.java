package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.feedback.FeedbackDto;
import com.example.qnuquiz.entity.Feedbacks;

@Mapper(componentModel = "spring")
public interface FeedbackMapper {

    @Mapping(source = "questions.content", target = "questionContent")
    @Mapping(source = "usersByUserId.username", target = "userName")
    @Mapping(source = "usersByReviewedBy.username", target = "reviewedBy")
    FeedbackDto toDto(Feedbacks feedback);

    List<FeedbackDto> toDtoList(List<Feedbacks> feedbacks);
}
