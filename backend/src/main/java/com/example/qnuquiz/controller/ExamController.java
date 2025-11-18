package com.example.qnuquiz.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.dto.exam.ExamResultDto;
import com.example.qnuquiz.dto.exam.ExamReviewDTO;
import com.example.qnuquiz.dto.exam.PracticeExamDTO;
import com.example.qnuquiz.dto.exam.QuestionDTO;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.ExamService;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@EnableMethodSecurity
@RequiredArgsConstructor
@RequestMapping("/api/exams/")
public class ExamController {

	private final ExamService examService;

	@GetMapping("/user")
	@PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
	public ResponseEntity<List<ExamDto>> getExamsByUserId(
			@RequestParam(value = "sort", required = false, defaultValue = "asc") String sort) {
		return ResponseEntity.ok(
				examService.getExamsByUserId(SecurityUtils.getCurrentUserId(), sort));
	}

	@PostMapping("/create")
	@PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
	public ResponseEntity<ExamDto> createExam(@RequestBody ExamDto dto) {
		return ResponseEntity.ok(examService.createExam(dto, SecurityUtils.getCurrentUserId()));
	}

	@PutMapping("/update/{id}")
	@PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
	public ResponseEntity<ExamDto> updateExam(@RequestBody ExamDto dto, @PathVariable Long id) {
		dto.setId(id);
		return ResponseEntity.ok(examService.updateExam(dto, SecurityUtils.getCurrentUserId()));
	}

	@DeleteMapping("/delete/{id}")
	@PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
	public ResponseEntity<Map<String, Object>> deleteExam(@PathVariable Long id) {
		try {
			examService.deleteExam(id);
			return ResponseEntity.ok(Map.of(
					"success", true,
					"message", "Xóa thành công"));
		} catch (Exception e) {
			return ResponseEntity.internalServerError().body(Map.of(
					"success", false,
					"message", "Lỗi khi xóa: " + e.getMessage()));
		}
	}

	@PostMapping("/{examId}/start")
	@PreAuthorize("hasAnyRole('ADMIN', 'STUDENT')")
	public ResponseEntity<ExamAttemptDto> startExam(@PathVariable Long examId) {
		return ResponseEntity.ok(examService.startExam(examId, SecurityUtils.getCurrentUserId()));
	}

	// trả lời câu hỏi
	@PostMapping("/{attemptId}/answer/{questionId}/{optionId}")
	public void submitAnswer(@PathVariable Long attemptId, @PathVariable Long questionId, @PathVariable Long optionId) {
		examService.submitAnswer(attemptId, questionId, optionId);
	}

	@PostMapping("/{attemptId}/finish")
	public ResponseEntity<ExamResultDto> finishExam(@PathVariable Long attemptId) {
		return ResponseEntity.ok(examService.finishExam(attemptId));
	}

	// Lấy danh sách câu hỏi cho bài thi
	@GetMapping("/{examId}/questions")
	public ResponseEntity<List<QuestionDTO>> getQuestions(@PathVariable Long examId) {
		return ResponseEntity.ok(examService.getQuestionsForExam(examId));
	}

	// Xem lại kết quả bài thi
	@GetMapping("/attempts/{attemptId}/review")
	public ResponseEntity<ExamReviewDTO> reviewExam(@PathVariable Long attemptId) {
		return ResponseEntity.ok(examService.reviewExamAttempt(attemptId));
	}


    @GetMapping("/getAll")
    public ResponseEntity<List<ExamDto>> getAllExams() {
        return ResponseEntity.ok(examService.getAllExams());
    }

}
