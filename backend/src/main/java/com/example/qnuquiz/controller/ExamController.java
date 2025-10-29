package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.service.ExamService;

@Controller
public class ExamController {
    private final ExamService examService;

    public ExamController(ExamService examService) {
        this.examService = examService;
    }

    @PostMapping("/{examId}/start/{studentId}")
    public ResponseEntity<ExamAttempts> startExam(@PathVariable Long examId,
                                                 @PathVariable Long studentId) {
        return ResponseEntity.ok(examService.startExam(examId, studentId));
    }

    @PostMapping("/{attemptId}/answer/{questionId}")
    public ResponseEntity<ExamAnswers> submitAnswer(@PathVariable Long attemptId,
                                                   @PathVariable Long questionId,
                                                   @RequestBody Long optionId) {
        return ResponseEntity.ok(examService.submitAnswer(attemptId, questionId, optionId));
    }

    @PostMapping("/{attemptId}/finish")
    public ResponseEntity<ExamAttempts> finishExam(@PathVariable Long attemptId) {
        return ResponseEntity.ok(examService.finishExam(attemptId));
    }

    @GetMapping("/{examId}/questions")
    public ResponseEntity<List<Questions>> getQuestions(@PathVariable Long examId) {
        return ResponseEntity.ok(examService.getQuestionsForExam(examId));
    }

}
