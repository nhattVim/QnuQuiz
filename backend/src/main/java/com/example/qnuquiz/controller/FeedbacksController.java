package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.feedback.FeedbacksDto;
import com.example.qnuquiz.entity.Feedbacks;
import com.example.qnuquiz.mapper.FeedbacksMapper;
import com.example.qnuquiz.service.FeedbacksService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/feedbacks")
public class FeedbacksController {

    private final FeedbacksService feedbacksService;
    private final FeedbacksMapper feedbacksMapper;

    @GetMapping
    public ResponseEntity<List<FeedbacksDto>> getAllFeedbacks() {
        List<Feedbacks> feedbacks = feedbacksService.getAllFeedbacks();
        List<FeedbacksDto> dtoList = feedbacksMapper.toDtoList(feedbacks);
        return ResponseEntity.ok(dtoList);
    }
}
