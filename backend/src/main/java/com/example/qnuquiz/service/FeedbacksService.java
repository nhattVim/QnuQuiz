package com.example.qnuquiz.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.entity.Feedbacks;
import com.example.qnuquiz.repository.FeedbacksRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FeedbacksService {

    private final FeedbacksRepository feedbacksRepository;

    public List<Feedbacks> getAllFeedbacks() {
        return feedbacksRepository.findAll();
    }
}
