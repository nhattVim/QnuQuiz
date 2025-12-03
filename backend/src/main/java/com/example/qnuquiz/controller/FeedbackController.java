package com.example.qnuquiz.controller;

import java.util.List;

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

import com.example.qnuquiz.dto.feedback.CreateFeedbackRequest;
import com.example.qnuquiz.dto.feedback.FeedbackDto;
import com.example.qnuquiz.dto.feedback.FeedbackTemplateDto;
import com.example.qnuquiz.dto.feedback.TeacherReplyRequest;
import com.example.qnuquiz.dto.feedback.UpdateFeedbackRequest;
import com.example.qnuquiz.service.FeedbackService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/feedbacks")
public class FeedbackController {

    private final FeedbackService feedbackService;

		@GetMapping
		@PreAuthorize("hasRole('ADMIN')")
		public ResponseEntity<List<FeedbackDto>> getAllFeedbacks() {
			return ResponseEntity.ok(feedbackService.getAllFeedbacks());
		}

		// Lấy feedback cho 1 câu hỏi, dùng cho màn hình danh sách
		@GetMapping("/question/{questionId}")
		public ResponseEntity<List<FeedbackDto>> getFeedbacksForQuestion(
				@PathVariable Long questionId,
				@RequestParam(required = false) String status) {
			return ResponseEntity.ok(feedbackService.getFeedbacksForQuestion(questionId, status));
		}

		// Lấy feedback theo examId (feedback tổng thể bài thi)
		@GetMapping("/exam/{examId}")
		public ResponseEntity<List<FeedbackDto>> getFeedbacksForExam(
				@PathVariable Long examId,
				@RequestParam(required = false) String status) {
			return ResponseEntity.ok(feedbackService.getFeedbacksForExam(examId, status));
		}

		// Tạo feedback (rating + content) cho màn hình đánh giá
		@PostMapping
		public ResponseEntity<FeedbackDto> createFeedback(@Valid @RequestBody CreateFeedbackRequest request) {
			return ResponseEntity.ok(feedbackService.createFeedback(request));
		}

		// Cập nhật feedback (dùng cho cả exam-level và question-level)
		@PutMapping("/{id}")
		public ResponseEntity<FeedbackDto> updateFeedback(
				@PathVariable Long id,
				@Valid @RequestBody UpdateFeedbackRequest request) {
			return ResponseEntity.ok(feedbackService.updateFeedback(id, request));
		}

		// Xóa feedback
		@DeleteMapping("/{id}")
		@PreAuthorize("hasRole('ADMIN')")
		public ResponseEntity<Void> deleteFeedback(@PathVariable Long id) {
			feedbackService.deleteFeedback(id);
			return ResponseEntity.noContent().build();
		}

		// Giáo viên phản hồi: lưu reply riêng, set reviewed_by & reviewed_at
		@PostMapping("/{id}/reply")
		public ResponseEntity<FeedbackDto> addTeacherReply(
				@PathVariable Long id,
				@Valid @RequestBody TeacherReplyRequest request) {
			return ResponseEntity.ok(feedbackService.addTeacherReply(id, request));
		}

		// Danh sách template/tag để client dùng fill nhanh vào ô Bình luận
		@GetMapping("/templates")
		public ResponseEntity<List<FeedbackTemplateDto>> getTemplates() {
			return ResponseEntity.ok(feedbackService.getTemplates());
		}
}
