package com.example.qnuquiz.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.analytics.ClassPerformanceDto;
import com.example.qnuquiz.dto.analytics.ExamAnalyticsDto;
import com.example.qnuquiz.dto.analytics.QuestionAnalyticsDto;
import com.example.qnuquiz.dto.analytics.RankingDto;
import com.example.qnuquiz.dto.analytics.ScoreDistributionDto;
import com.example.qnuquiz.dto.analytics.StudentAttemptDto;

@Service
public interface AnalyticsService {

    List<RankingDto> rankingAll();

    List<RankingDto> rankingAllThisWeek();

    List<RankingDto> rankingByExamId(Long examId);

    List<ExamAnalyticsDto> getExamAnalytics(String teacherId);

    List<ClassPerformanceDto> getClassPerformance(Long examId);

    List<ScoreDistributionDto> getScoreDistribution(String teacherId);

    List<StudentAttemptDto> getStudentAttempts(Long examId);

    List<QuestionAnalyticsDto> getQuestionAnalytics(Long examId);
}
