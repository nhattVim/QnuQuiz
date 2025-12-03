package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.analytics.ClassPerformanceDto;
import com.example.qnuquiz.dto.analytics.ExamAnalyticsDto;
import com.example.qnuquiz.dto.analytics.QuestionAnalyticsDto;
import com.example.qnuquiz.dto.analytics.RankingDto;
import com.example.qnuquiz.dto.analytics.ScoreDistributionDto;
import com.example.qnuquiz.dto.analytics.StudentAttemptDto;
import com.example.qnuquiz.service.AnalyticsService;

import lombok.RequiredArgsConstructor;

@RestController
@EnableMethodSecurity
@RequiredArgsConstructor
@RequestMapping("/api/analytics")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/ranking")
    @PreAuthorize("hasAnyRole('STUDENT')")
    public List<RankingDto> rankingAll() {
        return analyticsService.rankingAll();
    }

    @GetMapping("/ranking/week")
    @PreAuthorize("hasAnyRole('STUDENT')")
    public List<RankingDto> rankingThisWeek() {
        return analyticsService.rankingAllThisWeek();
    }

    @GetMapping("/ranking/{examId}")
    @PreAuthorize("hasAnyRole('STUDENT')")
    public List<RankingDto> rankingByExamId(@PathVariable Long examId) {
        return analyticsService.rankingByExamId(examId);
    }

    @GetMapping("/teacher/{teacherId}/exams")
    @PreAuthorize("hasRole('TEACHER')")
    public List<ExamAnalyticsDto> getExamAnalytics(@PathVariable String teacherId) {
        return analyticsService.getExamAnalytics(teacherId);
    }

    @GetMapping("/exam/{examId}/class-performance")
    @PreAuthorize("hasRole('TEACHER')")
    public List<ClassPerformanceDto> getClassPerformance(@PathVariable Long examId) {
        return analyticsService.getClassPerformance(examId);
    }

    @GetMapping("/teacher/{teacherId}/score-distribution")
    @PreAuthorize("hasRole('TEACHER')")
    public List<ScoreDistributionDto> getScoreDistribution(@PathVariable String teacherId) {
        return analyticsService.getScoreDistribution(teacherId);
    }

    @GetMapping("/exam/{examId}/attempts")
    @PreAuthorize("hasRole('TEACHER')")
    public List<StudentAttemptDto> getStudentAttempts(@PathVariable Long examId) {
        return analyticsService.getStudentAttempts(examId);
    }

    @GetMapping("/exam/{examId}/question-analytics")
    @PreAuthorize("hasRole('TEACHER')")
    public List<QuestionAnalyticsDto> getQuestionAnalytics(@PathVariable Long examId) {
        return analyticsService.getQuestionAnalytics(examId);
    }
}
