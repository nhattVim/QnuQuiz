package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.feedback.CreateFeedbackRequest;
import com.example.qnuquiz.dto.feedback.FeedbackDto;
import com.example.qnuquiz.dto.feedback.FeedbackTemplateDto;
import com.example.qnuquiz.dto.feedback.TeacherReplyRequest;
import com.example.qnuquiz.dto.feedback.UpdateFeedbackRequest;

public interface FeedbackService {

    List<FeedbackDto> getAllFeedbacks();

    List<FeedbackDto> getFeedbacksByUserId();

    FeedbackDto createFeedback(CreateFeedbackRequest request);

    List<FeedbackDto> getFeedbacksForQuestion(Long questionId, String status);

    List<FeedbackTemplateDto> getTemplates();

    List<FeedbackDto> getFeedbacksForExam(Long examId, String status);

    FeedbackDto updateFeedback(Long id, UpdateFeedbackRequest request);

    void deleteFeedback(Long id);

    FeedbackDto addTeacherReply(Long id, TeacherReplyRequest request);
}