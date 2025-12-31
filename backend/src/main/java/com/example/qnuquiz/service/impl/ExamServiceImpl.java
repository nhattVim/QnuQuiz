package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;

import com.example.qnuquiz.dto.exam.ExamAnswerReviewDTO;
import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamCategoryDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.dto.exam.ExamResultDto;
import com.example.qnuquiz.dto.exam.ExamReviewDTO;
import com.example.qnuquiz.dto.questions.QuestionDTO;
import com.example.qnuquiz.dto.questions.QuestionOptionDto;
import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.ExamCategories;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.ExamCategoryMapper;
import com.example.qnuquiz.mapper.ExamMapper;
import com.example.qnuquiz.mapper.QuestionMapper;
import com.example.qnuquiz.repository.ExamAnswerRepository;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.repository.ExamCategoryRepository;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.FeedbackRepository;
import com.example.qnuquiz.repository.QuestionOptionsRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.ExamService;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import jakarta.persistence.EntityNotFoundException;

@Service
@AllArgsConstructor
@Slf4j
public class ExamServiceImpl implements ExamService {

    private final ExamRepository examRepository;
    private final QuestionOptionsRepository optionRepo;
    private final QuestionRepository questionRepo;
    private final UserRepository userRepository;
    private final StudentRepository studentRepository;
    private final ExamCategoryRepository examCategoryRepository;

    private final ExamCategoryMapper examCategoryMapper;
    private final ExamMapper examMapper;

    private final QuestionRepository questionRepository;
    private final ExamAttemptRepository examAttemptRepository;
    private final ExamAnswerRepository examAnswerRepository;
    private final FeedbackRepository feedbackRepository;
    private final QuestionMapper questionMapper;
    private final com.example.qnuquiz.service.MediaFileService mediaFileService;

    @Override
    public void submitAnswer(Long attemptId, Long questionId, Long optionId) {
        // 1. Lấy attempt
        ExamAttempts attempt = examAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new EntityNotFoundException("Attempt not found: " + attemptId));

        // 2. Lấy option
        QuestionOptions option = optionRepo.findById(optionId)
                .orElseThrow(() -> new EntityNotFoundException("Option not found: " + optionId));

        // 4. Kiểm tra xem đã có câu trả lời cho attempt + question chưa
        Optional<ExamAnswers> existingOpt = examAnswerRepository.findByExamAttemptsIdAndQuestionsId(attemptId,
                questionId);

        ExamAnswers answer;
        if (existingOpt.isPresent()) {
            answer = existingOpt.get();
            answer.setQuestionOptions(option);
            answer.setIsCorrect(option.isIsCorrect());
        } else {
            answer = new ExamAnswers();
            answer.setExamAttempts(attempt);
            answer.setQuestions(option.getQuestions());
            answer.setQuestionOptions(option);
            answer.setIsCorrect(option.isIsCorrect());
            answer.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        }

        examAnswerRepository.save(answer);
    }

    @Override
    public void submitEssay(Long attemptId, Long questionId, String answerText) {
        ExamAttempts attempt = examAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new EntityNotFoundException("Attempt not found: " + attemptId));
        Questions question = questionRepo.findById(questionId)
                .orElseThrow(() -> new EntityNotFoundException("Question not found: " + questionId));

        ExamAnswers answer = new ExamAnswers();
        answer.setExamAttempts(attempt);
        answer.setQuestions(question);
        answer.setAnswerText(answerText);
        answer.setIsCorrect(null); // chưa chấm

        examAnswerRepository.save(answer);
    }

    @Override
    public ExamResultDto finishExam(Long attemptId) {
        ExamAttempts attempt = examAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new EntityNotFoundException("Attempt not found: " + attemptId));

        List<ExamAnswers> answers = examAnswerRepository.findByExamAttempts_Id(attemptId);

        long correctCount = answers.stream()
                .filter(a -> Boolean.TRUE.equals(a.getIsCorrect()))
                .count();

        long totalQuestions = answers.size();

        attempt.setScore((int) correctCount * 10);
        attempt.setSubmitted(true);
        attempt.setEndTime(Timestamp.from(Instant.now()));
        examAttemptRepository.save(attempt);

        return ExamResultDto.builder()
                .score(attempt.getScore())
                .correctCount(correctCount)
                .totalQuestions(totalQuestions)
                .build();
    }

    @Override
    public ExamAttemptDto startExam(Long examId) {
        Users user = getCurrentAuthenticatedUser();

        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new EntityNotFoundException("Student not found for user: " + user.getId()));

        log.debug("startExam called for exam {}, student {}", examId, student.getId());

        var allAttempts = examAttemptRepository
                .findByExamsIdAndStudentsIdOrderByCreatedAtDesc(examId, student.getId());

        log.debug("Found {} total attempts for exam {}", allAttempts.size(), examId);

        if (!allAttempts.isEmpty()) {
            ExamAttempts latestAttempt = allAttempts.get(0);

            if (!latestAttempt.isSubmitted()) {
                log.debug("Returning existing unfinished attempt {}, submitted={}", latestAttempt.getId(),
                        latestAttempt.isSubmitted());
                return ExamAttemptDto.builder()
                        .id(latestAttempt.getId())
                        .examId(latestAttempt.getExams().getId())
                        .startTime(latestAttempt.getStartTime())
                        .submit(latestAttempt.isSubmitted())
                        .build();
            }
            log.debug("Latest attempt {} already submitted. Creating new attempt.", latestAttempt.getId());
        }

        log.debug("Creating new attempt for exam {}", examId);
        ExamAttempts attempt = new ExamAttempts();

        attempt.setExams(examRepository.findById(examId)
                .orElseThrow(() -> new EntityNotFoundException("Exam not found: " + examId)));

        attempt.setStudents(student);
        attempt.setStartTime(new Timestamp(System.currentTimeMillis()));
        attempt.setSubmitted(false);
        attempt.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        ExamAttempts saved = examAttemptRepository.save(attempt);
        log.debug("New attempt created with id {}", saved.getId());

        return ExamAttemptDto.builder()
                .id(saved.getId())
                .examId(saved.getExams().getId())
                .startTime(saved.getStartTime())
                .submit(saved.isSubmitted())
                .build();

    }

    @Override
    public ExamDto createExam(ExamDto dto) {
        Users user = getCurrentAuthenticatedUser();
        Exams exam = examMapper.toEntity(dto);

        if (exam.getStartTime() != null && exam.getEndTime() != null) {
            if (!exam.getEndTime().after(exam.getStartTime())) {
                throw new IllegalArgumentException("End time must be after start time");
            }
        }

        ExamCategories category = examCategoryRepository
                .findById(dto.getCategoryId())
                .orElseThrow(() -> new EntityNotFoundException("Category not found: " + dto.getCategoryId()));

        exam.setExamCategories(category);
        exam.setUsers(user);
        exam.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        exam.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
        if (exam.getStatus() == null) {
            exam.setStatus("DRAFT");
        }

        Exams saved = examRepository.save(exam);
        return examMapper.toDto(saved);
    }

    @Override
    public List<ExamDto> getExamsByUserId(String sort) {
        Users user = getCurrentAuthenticatedUser();
        List<Exams> exams = examRepository.findByUsers_Id(user.getId());

        if ("desc".equalsIgnoreCase(sort)) {
            exams.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));
        } else {
            exams.sort((a, b) -> a.getCreatedAt().compareTo(b.getCreatedAt()));
        }

        return exams.stream()
                .map(exam -> {
                    ExamDto dto = examMapper.toDto(exam);
                    dto.setStatus(getComputedStatus(exam));
                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Override
    public ExamDto updateExam(ExamDto dto) {
        Users user = getCurrentAuthenticatedUser();

        Exams exam = examRepository.findById(dto.getId())
                .orElseThrow(() -> new EntityNotFoundException("Exam not found: " + dto.getId()));

        // Validate that endTime is after startTime
        if (dto.getStartTime() != null && dto.getEndTime() != null) {
            if (!dto.getEndTime().after(dto.getStartTime())) {
                throw new IllegalArgumentException("End time must be after start time");
            }
        }

        exam.setTitle(dto.getTitle());
        exam.setDescription(dto.getDescription());
        exam.setDurationMinutes(dto.getDurationMinutes());
        exam.setStartTime(dto.getStartTime());
        exam.setEndTime(dto.getEndTime());
        exam.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
        exam.setUsers(user);

        if ("DRAFT".equals(dto.getStatus())) {
            exam.setStatus("DRAFT");
        } else {
            exam.setStatus("PUBLISHED");
        }

        Exams saved = examRepository.save(exam);
        ExamDto resultDto = examMapper.toDto(saved);
        resultDto.setStatus(getComputedStatus(saved));

        return resultDto;
    }

    private String getComputedStatus(Exams exam) {
        if ("DRAFT".equals(exam.getStatus())) {
            return "DRAFT";
        }

        Timestamp startTime = exam.getStartTime();
        Timestamp endTime = exam.getEndTime();
        Timestamp now = Timestamp.from(Instant.now());

        if (startTime == null || endTime == null) {
            return "DRAFT";
        }

        if (now.after(startTime) && now.before(endTime)) {
            return "ACTIVE";
        } else if (now.after(endTime)) {
            return "CLOSED";
        } else {
            return "DRAFT";
        }
    }

    @Override
    public List<QuestionDTO> getQuestionsForExam(Long examId) {
        Exams exam = examRepository.findById(examId)
                .orElseThrow(() -> new EntityNotFoundException("Exam not found: " + examId));

        List<Questions> questions = questionRepository.findByExamsId(examId);
        if (questions.isEmpty()) {
            throw new EntityNotFoundException("No questions found for this exam");
        }
        List<Questions> selectedQuestions;
        if (!exam.isRandom()) {
            selectedQuestions = questions;
        } else {
            List<Questions> questionsRandom = new ArrayList<>(questions);
            Collections.shuffle(questionsRandom);
            selectedQuestions = questionsRandom.stream().limit(30).toList();
        }

        // Populate options and media files
        return selectedQuestions.stream().map(q -> {
            QuestionDTO dto = questionMapper.toQuestionDTO(q);
            // Lấy tất cả options của câu hỏi này
            List<QuestionOptionDto> optionDtos = optionRepo.findByQuestions_Id(q.getId())
                .stream()
                .map(option -> QuestionOptionDto.builder()
                    .id(option.getId())
                    .content(option.getContent())
                    .position(option.getPosition())
                    .correct(option.isIsCorrect())
                    .build())
                .toList();
            dto.setOptions(optionDtos);

            List<com.example.qnuquiz.dto.media.MediaFileDto> mediaFiles =
                mediaFileService.getMediaFilesByQuestionId(q.getId());
            dto.setMediaFiles(mediaFiles);

            if (!mediaFiles.isEmpty()) {
                dto.setMediaUrl(mediaFiles.get(0).getFileUrl());
            }

            return dto;
        }).toList();
    }

    @Override
    public ExamReviewDTO reviewExamAttempt(Long attemptId) {
        ExamAttempts attempt = examAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new EntityNotFoundException("Exam attempt not found: " + attemptId));

        List<ExamAnswers> answers = examAnswerRepository.findByExamAttempts_Id(attemptId);

        List<ExamAnswerReviewDTO> answerDTOs = answers.stream()
                .map(examMapper::toExamAnswerReviewDTO)
                .toList();

        return ExamReviewDTO.builder()
                .examAttemptId(attempt.getId())
                .examTitle(attempt.getExams().getTitle())
                .score(attempt.getScore() != null ? attempt.getScore() : 0)
                .answers(answerDTOs)
                .build();
    }

    @Override
    @Transactional
    public void deleteExam(Long id) {
        // Collect question ids for this exam (to clean related feedbacks if needed)
        List<Questions> questions = questionRepository.findByExamsId(id);
        List<Long> questionIds = questions.stream()
                .map(Questions::getId)
                .toList();

        // 1) Remove feedbacks linked to exam and its questions (FK constraints)
        feedbackRepository.deleteByExamId(id);
        if (!questionIds.isEmpty()) {
            feedbackRepository.deleteByQuestionIds(questionIds);
        }

        // 2) Remove exam answers via attempt ids (some DBs may not enforce ON DELETE CASCADE)
        List<Long> attemptIds = examAttemptRepository.findIdsByExamId(id);
        if (!attemptIds.isEmpty()) {
            examAnswerRepository.deleteByAttemptIds(attemptIds);
            examAttemptRepository.deleteByExamId(id);
        }

        // 3) Delete question options (some DBs may not have ON DELETE CASCADE)
        if (!questionIds.isEmpty()) {
            optionRepo.deleteAllByQuestions_IdIn(questionIds);
            for (Long qid : questionIds) {
                try {
                    mediaFileService.deleteMediaFilesByQuestionId(qid);
                } catch (Exception e) {
                    log.warn("Failed to delete media files for question {}: {}", qid, e.getMessage());
                }
            }
            questionRepository.deleteAllById(questionIds);
        }

        // 4) Finally delete exam
        examRepository.deleteById(id);
    }

    @Override
    public List<ExamDto> getAllExams() {
        List<Exams> exams = examRepository.findAll();
        return examMapper.toDtoList(exams);
    }

    private Users getCurrentAuthenticatedUser() {
        UUID userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new IllegalArgumentException("User not authenticated");
        }
        return userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found: " + userId));
    }

    public List<ExamCategoryDto> getAllCategories() {
        List<ExamCategories> categories = examCategoryRepository.findAll();

        return categories.stream().map(cat -> {
            ExamCategoryDto dto = examCategoryMapper.toDto(cat);

            Long totalExams = examRepository.findByExamCategories_Id(cat.getId())
                    .stream()
                    .filter(exam -> !"DRAFT".equalsIgnoreCase(exam.getStatus()))
                    .count();

            dto.setTotalExams(totalExams);
            return dto;
        }).toList();
    }

    @Override
    public List<ExamDto> getExamsByCategory(Long categoryId) {

        examCategoryRepository.findById(categoryId)
                .orElseThrow(() -> new EntityNotFoundException("Exam category not found: " + categoryId));

        List<Exams> exams = examRepository.findByExamCategories_Id(categoryId);

        // Get current student
        UUID userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            throw new IllegalArgumentException("User not authenticated");
        }
        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found: " + userId));
        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new EntityNotFoundException("Student not found for user: " + userId));

        return exams.stream()
                .filter(exam -> !"DRAFT".equalsIgnoreCase(exam.getStatus()))
                .map(exam -> {
                    ExamDto dto = examMapper.toDto(exam);
                    String computedStatus = getComputedStatus(exam);
                    dto.setStatus(computedStatus);

                    var allAttempts = examAttemptRepository
                            .findByExamsIdAndStudentsIdOrderByCreatedAtDesc(exam.getId(), student.getId());

                    dto.setHasAttempt(!allAttempts.isEmpty());

                    if (!allAttempts.isEmpty()) {
                        ExamAttempts latestAttempt = allAttempts.get(0);
                        dto.setHasUnfinishedAttempt(!latestAttempt.isSubmitted());
                    } else {
                        dto.setHasUnfinishedAttempt(false);
                    }

                    return dto;
                })
                .toList();
    }

    @Override
    public ExamAttemptDto getLatestAttempt(Long examId) {
        Users user = getCurrentAuthenticatedUser();
        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new EntityNotFoundException("Student not found for user: " + user.getId()));

        // Get all attempts ordered by createdAt DESC
        var allAttempts = examAttemptRepository.findByExamsIdAndStudentsIdOrderByCreatedAtDesc(examId, student.getId());

        if (allAttempts.isEmpty()) {
            throw new EntityNotFoundException("No attempts found for exam: " + examId);
        }

        ExamAttempts latestAttempt = allAttempts.get(0);
        return ExamAttemptDto.builder()
                .id(latestAttempt.getId())
                .examId(latestAttempt.getExams().getId())
                .startTime(latestAttempt.getStartTime())
                .submit(latestAttempt.isSubmitted())
                .build();
    }

}
