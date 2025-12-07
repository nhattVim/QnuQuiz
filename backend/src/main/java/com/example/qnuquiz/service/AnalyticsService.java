package com.example.qnuquiz.service;

import com.example.qnuquiz.dto.analytics.AdminExamAnalyticsDto;
import com.example.qnuquiz.dto.analytics.AdminQuestionAnalyticsDto;
import com.example.qnuquiz.dto.analytics.ClassPerformanceDto;
import com.example.qnuquiz.dto.analytics.ExamAnalyticsDto;
import com.example.qnuquiz.dto.analytics.QuestionAnalyticsDto;
import com.example.qnuquiz.dto.analytics.RankingDto;
import com.example.qnuquiz.dto.analytics.ScoreDistributionDto;
import com.example.qnuquiz.dto.analytics.StudentAttemptDto;
import com.example.qnuquiz.dto.analytics.UserAnalyticsDto;
import org.springframework.stereotype.Service;

import java.util.List;

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

    UserAnalyticsDto getUserAnalytics();

    AdminExamAnalyticsDto getExamAnalyticsAdmin();

    AdminQuestionAnalyticsDto getQuestionAnalyticsAdmin();

    byte[] exportUserAnalyticsCsv();

    byte[] exportExamAnalyticsCsv();

    byte[] exportQuestionAnalyticsCsv();
}
