package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.feedback.CreateFeedbackRequest;
import com.example.qnuquiz.dto.feedback.FeedbackDto;
import com.example.qnuquiz.dto.feedback.FeedbackTemplateDto;
import com.example.qnuquiz.dto.feedback.TeacherReplyRequest;
import com.example.qnuquiz.dto.feedback.UpdateFeedbackRequest;
import com.example.qnuquiz.service.FeedbackService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/feedbacks")
public class FeedbackController {

    private final FeedbackService feedbackService;

    @GetMapping
    public ResponseEntity<List<FeedbackDto>> getAllFeedbacks() {
        return ResponseEntity.ok(feedbackService.getAllFeedbacks());
    }

    @GetMapping("/question/{questionId}")
    public ResponseEntity<List<FeedbackDto>> getFeedbacksForQuestion(
            @PathVariable Long questionId,
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(feedbackService.getFeedbacksForQuestion(questionId, status));
    }

    @GetMapping("/exam/{examId}")
    public ResponseEntity<List<FeedbackDto>> getFeedbacksForExam(
            @PathVariable Long examId,
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(feedbackService.getFeedbacksForExam(examId, status));
    }

    @PostMapping
    public ResponseEntity<FeedbackDto> createFeedback(@Valid @RequestBody CreateFeedbackRequest request) {
        return ResponseEntity.ok(feedbackService.createFeedback(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<FeedbackDto> updateFeedback(
            @PathVariable Long id,
            @Valid @RequestBody UpdateFeedbackRequest request) {
        return ResponseEntity.ok(feedbackService.updateFeedback(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFeedback(@PathVariable Long id) {
        feedbackService.deleteFeedback(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/reply")
    public ResponseEntity<FeedbackDto> addTeacherReply(
            @PathVariable Long id,
            @Valid @RequestBody TeacherReplyRequest request) {
        return ResponseEntity.ok(feedbackService.addTeacherReply(id, request));
    }

    @GetMapping("/templates")
    public ResponseEntity<List<FeedbackTemplateDto>> getTemplates() {
        return ResponseEntity.ok(feedbackService.getTemplates());
    }
}