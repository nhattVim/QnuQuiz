package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.feedback.CreateFeedbackRequest;
import com.example.qnuquiz.dto.feedback.FeedbackDto;
import com.example.qnuquiz.dto.feedback.FeedbackTemplateDto;
import com.example.qnuquiz.dto.feedback.TeacherReplyRequest;
import com.example.qnuquiz.dto.feedback.UpdateFeedbackRequest;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.Feedbacks;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.FeedbackMapper;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.FeedbackRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.FeedbackService;

import jakarta.persistence.EntityNotFoundException;
import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class FeedbackServiceImpl implements FeedbackService {

    private final FeedbackMapper feedbacksMapper;
    private final FeedbackRepository feedbacksRepository;
    private final UserRepository userRepository;
    private final QuestionRepository questionRepository;
    private final ExamRepository examRepository;

    @Override
    public List<FeedbackDto> getAllFeedbacks() {
        return feedbacksMapper.toDtoList(feedbacksRepository.findAll());
    }

    @Override
    public List<FeedbackDto> getFeedbacksByUserId() {
        Users user = getCurrentAuthenticatedUser();
        return feedbacksMapper.toDtoList(feedbacksRepository.findByUsersByUserId(user));
    }

    @Override
    public FeedbackDto createFeedback(CreateFeedbackRequest request) {
        if (request.getRating() != null
                && (request.getRating() < 1 || request.getRating() > 5)) {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }

        // If questionId is provided, examId is required (feedback on specific question)
        // If only examId is provided, it's exam-level feedback
        if (request.getQuestionId() != null && request.getExamId() == null) {
            throw new IllegalArgumentException("When rating a question, examId must also be provided");
        }

        if (request.getExamId() == null) {
            throw new IllegalArgumentException("examId is required");
        }

        var currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw new IllegalArgumentException("Current user not found");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        Feedbacks feedback = new Feedbacks();
        feedback.setUsersByUserId(user);

        // Set exam (always required)
        Exams exam = examRepository.findById(request.getExamId())
                .orElseThrow(() -> new EntityNotFoundException("Exam not found"));
        feedback.setExams(exam);

        // If questionId is provided, set question and check duplicate question feedback
        if (request.getQuestionId() != null) {
            Questions question = questionRepository.findById(request.getQuestionId())
                    .orElseThrow(() -> new EntityNotFoundException("Question not found"));

            feedbacksRepository.findByUsersByUserIdAndQuestions(user, question)
                    .ifPresent(existing -> {
                        throw new IllegalArgumentException("You have already given feedback for this question");
                    });

            feedback.setQuestions(question);
        } else {
            // For exam-level feedback, check duplicate exam feedback
            feedbacksRepository.findByUsersByUserIdAndExams(user, exam)
                    .ifPresent(existing -> {
                        throw new IllegalArgumentException("You have already given feedback for this exam");
                    });
        }

        feedback.setContent(request.getContent());
        feedback.setRating(request.getRating());
        feedback.setStatus("PENDING");
        feedback.setCreatedAt(Timestamp.from(Instant.now()));

        Feedbacks saved = feedbacksRepository.save(feedback);
        return feedbacksMapper.toDto(saved);
    }

    @Override
    public List<FeedbackDto> getFeedbacksForQuestion(Long questionId, String status) {
        List<Feedbacks> feedbacks;
        if (status == null || status.isBlank()) {
            feedbacks = feedbacksRepository.findByQuestions_Id(questionId);
        } else {
            feedbacks = feedbacksRepository.findByQuestions_IdAndStatus(
                    questionId,
                    status.toUpperCase(Locale.ROOT));
        }
        return feedbacksMapper.toDtoList(feedbacks);
    }

    @Override
    public List<FeedbackTemplateDto> getTemplates() {
        // Các template/tag mẫu cho màn hình đánh giá
        return List.of(
                new FeedbackTemplateDto("GOOD_KNOWLEDGE", "Kiến thức hay",
                        "Câu hỏi rất hay, kiến thức bổ ích!"),
                new FeedbackTemplateDto("NEED_IMPROVEMENT", "Cần cải thiện",
                        "Câu hỏi cần được chỉnh sửa để rõ ràng hơn."),
                new FeedbackTemplateDto("NOT_ACCURATE", "Chưa đúng lắm",
                        "Nội dung câu hỏi/đáp án chưa thật sự chính xác."),
                new FeedbackTemplateDto("VERY_GOOD", "Câu hỏi rất hay",
                        "Câu hỏi rất hay và thú vị!"),
                new FeedbackTemplateDto("EXCELLENT", "Tuyệt vời",
                        "Câu hỏi tuyệt vời, không có gì để chê."));
    }

    @Override
    public List<FeedbackDto> getFeedbacksForExam(Long examId, String status) {
        List<Feedbacks> feedbacks;
        if (status == null || status.isBlank()) {
            feedbacks = feedbacksRepository.findByExams_Id(examId);
        } else {
            feedbacks = feedbacksRepository.findByExams_IdAndStatus(
                    examId,
                    status.toUpperCase(Locale.ROOT));
        }
        return feedbacksMapper.toDtoList(feedbacks);
    }

    @Override
    public FeedbackDto updateFeedback(Long id, UpdateFeedbackRequest request) {
        Feedbacks feedback = feedbacksRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Feedback not found"));

        if (request.getContent() != null && !request.getContent().isBlank()) {
            feedback.setContent(request.getContent());
        }

        if (request.getRating() != null) {
            if (request.getRating() < 1 || request.getRating() > 5) {
                throw new IllegalArgumentException("Rating must be between 1 and 5");
            }
            feedback.setRating(request.getRating());
        }

        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            feedback.setStatus(request.getStatus().toUpperCase(Locale.ROOT));
        }

        Feedbacks saved = feedbacksRepository.save(feedback);
        return feedbacksMapper.toDto(saved);
    }

    @Override
    public void deleteFeedback(Long id) {
        if (!feedbacksRepository.existsById(id)) {
            throw new EntityNotFoundException("Feedback not found");
        }
        feedbacksRepository.deleteById(id);
    }

    @Override
    public FeedbackDto addTeacherReply(Long id, TeacherReplyRequest request) {
        var currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw new IllegalArgumentException("Current user not found");
        }

        Users teacher = userRepository.findById(currentUserId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        Feedbacks feedback = feedbacksRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Feedback not found"));

        feedback.setTeacherReply(request.getReply());
        feedback.setUsersByReviewedBy(teacher);
        feedback.setReviewedAt(Timestamp.from(Instant.now()));

        String status = request.getStatus();
        if (status == null || status.isBlank()) {
            status = "REVIEWED";
        }
        feedback.setStatus(status.toUpperCase(Locale.ROOT));

        Feedbacks saved = feedbacksRepository.save(feedback);
        return feedbacksMapper.toDto(saved);
    }

    private Users getCurrentAuthenticatedUser() {
        UUID userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new IllegalArgumentException("Current user not found");
        }
        return userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
    }

}