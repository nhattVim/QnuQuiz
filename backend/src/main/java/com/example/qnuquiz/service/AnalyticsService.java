package com.example.qnuquiz.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.analytics.RankingDto;

@Service
public interface AnalyticsService {

    List<RankingDto> rankingAll();

    List<RankingDto> rankingAllThisWeek();

    List<RankingDto> rankingByExamId(Long examId);
}
