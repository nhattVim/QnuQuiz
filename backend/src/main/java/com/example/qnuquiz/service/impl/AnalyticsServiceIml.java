package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.analytics.RankingDto;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.service.AnalyticsService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class AnalyticsServiceIml implements AnalyticsService {

    private final ExamAttemptRepository examAttemptRepository;

    @Override
    public List<RankingDto> rankingAll() {
        return examAttemptRepository.rankingAll();
    }

    @Override
    public List<RankingDto> rankingAllThisWeek() {
        Timestamp weekAgo = new Timestamp(System.currentTimeMillis() - 7L * 86400 * 1000);
        return examAttemptRepository.rankingAllThisWeek(weekAgo);
    }

    @Override
    public List<RankingDto> rankingByExamId(Long examId) {
        return examAttemptRepository.rankingByExamId(examId);
    }

}
