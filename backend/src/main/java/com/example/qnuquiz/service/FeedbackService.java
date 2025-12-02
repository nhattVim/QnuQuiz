package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.feedback.FeedbackDto;

public interface FeedbackService {

    List<FeedbackDto> getAllFeedbacks();

    void deleteFeedback(Long id);
}
