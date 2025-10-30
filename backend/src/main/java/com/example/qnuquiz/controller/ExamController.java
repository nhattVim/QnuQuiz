package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.qnuquiz.dto.exam.AnswerResultDto;
import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.QuestionExamDto;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.service.ExamService;

@Controller
public class ExamController {
    private final ExamService examService;

    public ExamController(ExamService examService) {
        this.examService = examService;
    }

    @PostMapping("/{examId}/start/{studentId}")
    public ResponseEntity<ExamAttemptDto> startExam(@PathVariable Long examId,
                                                 @PathVariable Long studentId) {
        return ResponseEntity.ok(examService.startExam(examId, studentId));
    }

    @PostMapping("/{attemptId}/answer/{questionId}")
    public void submitAnswer(@PathVariable Long attemptId,
                                                   @PathVariable Long questionId,
                                                   @RequestBody Long optionId) {
       examService.submitAnswer(attemptId, questionId, optionId);
    }

    @PostMapping("/{attemptId}/finish")
    public ResponseEntity<ExamAttempts> finishExam(@PathVariable Long attemptId) {
        return ResponseEntity.ok(examService.finishExam(attemptId));
    }

    // Khi làm bài: chỉ hiển thị câu hỏi + đáp án + câu trả lời
    @GetMapping("/{examId}/questions")
    public ResponseEntity<List<QuestionExamDto>> getQuestions(@PathVariable Long examId,
                                                          @RequestParam Long attemptId) {
        return ResponseEntity.ok(examService.getQuestionsForExam(examId, attemptId));
    }

    // Sau khi nộp: hiển thị kết quả + đáp án đúng/sai
    @GetMapping("/attempts/{attemptId}/results")
    public ResponseEntity<List<AnswerResultDto>> getResults(@PathVariable Long attemptId) {
        return ResponseEntity.ok(examService.getResultForAttempt(attemptId));
    }


}
