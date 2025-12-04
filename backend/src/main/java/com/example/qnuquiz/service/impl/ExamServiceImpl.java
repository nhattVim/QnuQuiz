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

import com.example.qnuquiz.dto.exam.ExamAnswerReviewDTO;
import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamCategoryDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.dto.exam.ExamResultDto;
import com.example.qnuquiz.dto.exam.ExamReviewDTO;
import com.example.qnuquiz.dto.questions.QuestionDTO;
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
import com.example.qnuquiz.repository.QuestionOptionsRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.ExamService;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

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
    private final QuestionMapper questionMapper;

    @Override
    public void submitAnswer(Long attemptId, Long questionId, Long optionId) {
        // 1. Lấy attempt
        ExamAttempts attempt = examAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new RuntimeException("Attempt not found: " + attemptId));

        // 2. Lấy option
        QuestionOptions option = optionRepo.findById(optionId)
                .orElseThrow(() -> new RuntimeException("Option not found: " + optionId));

        // 4. Kiểm tra xem đã có câu trả lời cho attempt + question chưa
        Optional<ExamAnswers> existingOpt = examAnswerRepository.findByExamAttemptsIdAndQuestionsId(attemptId,
                questionId);

        ExamAnswers answer;
        if (existingOpt.isPresent()) {
            // Nếu đã có thì cập nhật
            answer = existingOpt.get();
            answer.setQuestionOptions(option);
            answer.setIsCorrect(option.isIsCorrect());
        } else {
            // Nếu chưa có thì tạo mới
            answer = new ExamAnswers();
            answer.setExamAttempts(attempt);
            answer.setQuestions(option.getQuestions());
            answer.setQuestionOptions(option);
            answer.setIsCorrect(option.isIsCorrect());
            answer.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        }

        // 5. Lưu
        examAnswerRepository.save(answer);
    }

    @Override
    public void submitEssay(Long attemptId, Long questionId, String answerText) {
        ExamAttempts attempt = examAttemptRepository.findById(attemptId).orElseThrow();
        Questions question = questionRepo.findById(questionId).orElseThrow();

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
                .orElseThrow(() -> new RuntimeException("Attempt not found"));

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

        // Tìm student tương ứng với user
        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        log.debug("startExam called for exam {}, student {}", examId, student.getId());

        // Tìm attempt gần nhất (bất kể submitted hay chưa)
        var allAttempts = examAttemptRepository
                .findByExamsIdAndStudentsIdOrderByCreatedAtDesc(examId, student.getId());

        log.debug("Found {} total attempts for exam {}", allAttempts.size(), examId);

        // Kiểm tra attempt gần nhất
        if (!allAttempts.isEmpty()) {
            ExamAttempts latestAttempt = allAttempts.get(0);

            // Nếu attempt gần nhất CHƯA submit (submitted = false) → return để continue
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
            // Nếu attempt gần nhất ĐÃ submit (submitted = true) → tạo attempt mới
            log.debug("Latest attempt {} already submitted. Creating new attempt.", latestAttempt.getId());
        }

        // Tạo attempt mới
        log.debug("Creating new attempt for exam {}", examId);
        ExamAttempts attempt = new ExamAttempts();

        // Lấy exam
        attempt.setExams(examRepository.findById(examId)
                .orElseThrow(() -> new RuntimeException("Exam not found")));

        // Gán student vào attempt
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

        ExamCategories category = examCategoryRepository
                .findById(dto.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));

        exam.setExamCategories(category);
        exam.setUsers(user);
        exam.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        exam.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

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
                .orElseThrow(() -> new RuntimeException("Exam not found"));

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
                .orElseThrow(() -> new RuntimeException("Exam not found"));
        ;

        List<Questions> questions = questionRepository.findByExamsId(examId);
        if (questions.isEmpty()) {
            throw new RuntimeException("No questions found for this exam");
        }

        if (!exam.isRandom()) {
            return questions.stream()
                    .map(questionMapper::toQuestionDTO)
                    .toList();
        }

        List<Questions> questionsRandom = new ArrayList<>(questions);

        // Shuffle danh sách
        Collections.shuffle(questionsRandom);

        // Giới hạn số lượng
        List<Questions> selected = questionsRandom.stream()
                .limit(30)
                .collect(Collectors.toList());
        return selected.stream()
                .map(questionMapper::toQuestionDTO)
                .toList();
    }

    @Override
    public ExamReviewDTO reviewExamAttempt(Long attemptId) {
        ExamAttempts attempt = examAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new RuntimeException("Exam attempt not found"));

        List<ExamAnswers> answers = examAnswerRepository.findByExamAttempts_Id(attemptId);

        // Map từng ExamAnswers -> ExamAnswerReviewDTO
        List<ExamAnswerReviewDTO> answerDTOs = answers.stream()
                .map(examMapper::toExamAnswerReviewDTO) // dùng mapper để convert
                .toList();

        return ExamReviewDTO.builder()
                .examAttemptId(attempt.getId())
                .examTitle(attempt.getExams().getTitle())
                .score(attempt.getScore() != null ? attempt.getScore() : 0)
                .answers(answerDTOs)
                .build();
    }

    @Override
    public void deleteExam(Long id) {
        examRepository.deleteById(id);
    }

    @Override
    public List<ExamDto> getAllExams() {
        List<Exams> exams = examRepository.findAll();
        return examMapper.toDtoList(exams);
    }

    private Users getCurrentAuthenticatedUser() {
        UUID userId = SecurityUtils.getCurrentUserId();
        userId = userId == null ? null : userId;
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
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
                .orElseThrow(() -> new RuntimeException("Exam category not found"));

        List<Exams> exams = examRepository.findByExamCategories_Id(categoryId);

        // Get current student
        UUID userId = SecurityUtils.getCurrentUserId();
        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        return exams.stream()
                .filter(exam -> !"DRAFT".equalsIgnoreCase(exam.getStatus()))
                .map(exam -> {
                    ExamDto dto = examMapper.toDto(exam);
                    String computedStatus = getComputedStatus(exam);
                    dto.setStatus(computedStatus);

                    // Tìm tất cả attempts của student cho exam này
                    var allAttempts = examAttemptRepository
                            .findByExamsIdAndStudentsIdOrderByCreatedAtDesc(exam.getId(), student.getId());

                    // Set hasAttempt = true nếu có attempt (bất kể submitted hay không)
                    dto.setHasAttempt(!allAttempts.isEmpty());

                    if (!allAttempts.isEmpty()) {
                        ExamAttempts latestAttempt = allAttempts.get(0);
                        // Set hasUnfinishedAttempt=true chỉ khi attempt gần nhất chưa submit
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
                .orElseThrow(() -> new RuntimeException("Student not found"));

        // Get all attempts ordered by createdAt DESC
        var allAttempts = examAttemptRepository.findByExamsIdAndStudentsIdOrderByCreatedAtDesc(examId, student.getId());

        if (allAttempts.isEmpty()) {
            throw new RuntimeException("No attempts found for this exam");
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
