package com.example.qnuquiz.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.qnuquiz.dto.questions.IdsRequest;
import com.example.qnuquiz.dto.questions.QuestionFullDto;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.QuestionService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/questions")
public class QuestionController {

    private final QuestionService questionService;

    @PostMapping("/import")
    public ResponseEntity<String> importQuestions(
            @RequestParam("file") MultipartFile file,
            @RequestParam("examId") Long examId) {
        try {
            questionService.importQuestionsFromExcel(file, SecurityUtils.getCurrentUserId(), examId);
            return ResponseEntity.ok("Data import successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body("Failed to import data: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<List<QuestionFullDto>> getQuestions(@RequestParam("examId") Long examId) {
        return ResponseEntity.ok(questionService.getQuestions(examId));
    }

    @DeleteMapping("/delete")
    public ResponseEntity<Map<String, Object>> deleteQuestions(@RequestBody IdsRequest request) {
        try {
            if (request.getIds() == null || request.getIds().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Danh sách ID rỗng"));
            }

            questionService.deleteQuestion(request.getIds());

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Xóa thành công"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of(
                    "success", false,
                    "message", "Lỗi khi xóa: " + e.getMessage()));
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<QuestionFullDto> updateQuestion(@RequestBody QuestionFullDto dto, @PathVariable Long id) {
        dto.setId(id);
        return ResponseEntity.ok(questionService.updateQuestion(dto));
    }
}
