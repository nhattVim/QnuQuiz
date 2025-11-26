package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.analytics.RankingDto;
import com.example.qnuquiz.service.ExamService;

import lombok.RequiredArgsConstructor;

@RestController
@EnableMethodSecurity
@RequiredArgsConstructor
@RequestMapping("/api/analytics")
public class AnalyticsController {

    private final ExamService examService;

    @GetMapping("/ranking")
    @PreAuthorize("hasAnyRole('STUDENT')")
    public List<RankingDto> rankingAll() {
        return examService.rankingAll();
    }

    @GetMapping("/ranking/week")
    @PreAuthorize("hasAnyRole('STUDENT')")
    public List<RankingDto> rankingThisWeek() {
        return examService.rankingAllThisWeek();
    }
}
