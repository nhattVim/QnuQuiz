package com.example.qnuquiz.controller;

import com.example.qnuquiz.dto.analytics.*;
import com.example.qnuquiz.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
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

    @GetMapping("/admin/users/export")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<byte[]> exportUserAnalyticsCsv() {
        byte[] csvBytes = analyticsService.exportUserAnalyticsCsv();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv"));
        headers.setContentDispositionFormData("attachment", "user_analytics.csv");
        return ResponseEntity.ok()
                .headers(headers)
                .body(csvBytes);
    }

    @GetMapping("/admin/exams/export")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<byte[]> exportExamAnalyticsCsv() {
        byte[] csvBytes = analyticsService.exportExamAnalyticsCsv();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv"));
        headers.setContentDispositionFormData("attachment", "exam_analytics.csv");
        return ResponseEntity.ok()
                .headers(headers)
                .body(csvBytes);
    }

    @GetMapping("/admin/questions/export")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<byte[]> exportQuestionAnalyticsCsv() {
        byte[] csvBytes = analyticsService.exportQuestionAnalyticsCsv();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv"));
        headers.setContentDispositionFormData("attachment", "question_analytics.csv");
        return ResponseEntity.ok()
                .headers(headers)
                .body(csvBytes);
    }
}
