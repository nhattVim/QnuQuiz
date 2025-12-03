package com.example.qnuquiz.controller;

import com.example.qnuquiz.dto.analytics.*;
import com.example.qnuquiz.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

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
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public List<ExamAnalyticsDto> getExamAnalytics(@PathVariable String teacherId) {
        return analyticsService.getExamAnalytics(teacherId);
    }

    @GetMapping("/exam/{examId}/class-performance")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public List<ClassPerformanceDto> getClassPerformance(@PathVariable Long examId) {
        return analyticsService.getClassPerformance(examId);
    }

    @GetMapping("/teacher/{teacherId}/score-distribution")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public List<ScoreDistributionDto> getScoreDistribution(@PathVariable String teacherId) {
        return analyticsService.getScoreDistribution(teacherId);
    }

    @GetMapping("/exam/{examId}/attempts")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public List<StudentAttemptDto> getStudentAttempts(@PathVariable Long examId) {
        return analyticsService.getStudentAttempts(examId);
    }

    @GetMapping("/exam/{examId}/question-analytics")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public List<QuestionAnalyticsDto> getQuestionAnalytics(@PathVariable Long examId) {
        return analyticsService.getQuestionAnalytics(examId);
    }

    @GetMapping("/admin/users")
    @PreAuthorize("hasRole('ADMIN')")
    public UserAnalyticsDto getUserAnalytics() {
        return analyticsService.getUserAnalytics();
    }

    @GetMapping("/admin/exams")
    @PreAuthorize("hasRole('ADMIN')")
    public AdminExamAnalyticsDto getExamAnalyticsAdmin() {
        return analyticsService.getExamAnalyticsAdmin();
    }

    @GetMapping("/admin/questions")
    @PreAuthorize("hasRole('ADMIN')")
    public AdminQuestionAnalyticsDto getQuestionAnalyticsAdmin() {
        return analyticsService.getQuestionAnalyticsAdmin();
    }
}
