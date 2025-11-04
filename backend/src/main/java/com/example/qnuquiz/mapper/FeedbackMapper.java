package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.feedback.FeedbackDto;
import com.example.qnuquiz.entity.Feedbacks;

@Mapper(componentModel = "spring")
public interface FeedbackMapper {

	@Mapping(target = "questionContent", ignore = true)
	@Mapping(target = "reviewedBy", ignore = true)
	@Mapping(target = "userName", ignore = true)
	FeedbackDto toDto(Feedbacks feedback);

	List<FeedbackDto> toDtoList(List<Feedbacks> feedbacks);
}
