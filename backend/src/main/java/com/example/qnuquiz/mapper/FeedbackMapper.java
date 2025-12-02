package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.example.qnuquiz.dto.feedback.FeedbackDto;
import com.example.qnuquiz.entity.Feedbacks;

@Mapper(componentModel = "spring")
public interface FeedbackMapper {

	@Mapping(target = "questionContent", ignore = true)
	@Mapping(target = "reviewedBy", ignore = true)
	@Mapping(target = "userName", ignore = true)
	FeedbackDto toDto(Feedbacks feedback);

	List<FeedbackDto> toDtoList(List<Feedbacks> feedbacks);

	@AfterMapping
	default void enrichDto(Feedbacks feedback, @MappingTarget FeedbackDto dto) {
		if (feedback.getQuestions() != null) {
			dto.setQuestionContent(feedback.getQuestions().getContent());
		}

		if (feedback.getUsersByUserId() != null) {
			String fullName = feedback.getUsersByUserId().getFullName();
			dto.setUserName(fullName != null ? fullName : feedback.getUsersByUserId().getUsername());
		}

		if (feedback.getUsersByReviewedBy() != null) {
			String fullName = feedback.getUsersByReviewedBy().getFullName();
			dto.setReviewedBy(fullName != null ? fullName : feedback.getUsersByReviewedBy().getUsername());
		}
	}
}
