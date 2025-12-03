package com.example.qnuquiz.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.feedback.FeedbackDto;
import com.example.qnuquiz.mapper.FeedbackMapper;
import com.example.qnuquiz.repository.FeedbackRepository;
import com.example.qnuquiz.service.FeedbackService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class FeedbackServiceImpl implements FeedbackService {

    private final FeedbackMapper feedbacksMapper;
    private final FeedbackRepository feedbacksRepository;

    @Override
    public List<FeedbackDto> getAllFeedbacks() {
        return feedbacksMapper.toDtoList(feedbacksRepository.findAll());
    }

    @Override
    public void deleteFeedback(Long id) {
        feedbacksRepository.deleteById(id);
    }

}
