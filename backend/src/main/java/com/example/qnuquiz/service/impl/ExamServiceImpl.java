package com.example.qnuquiz.service.impl;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.ExamMapper;
import com.example.qnuquiz.repository.ExamAnswerRepository;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.QuestionOptionsRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.service.ExamService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class ExamServiceImpl implements ExamService {

    private final ExamRepository examRepository;
    private final ExamAttemptRepository attemptRepo;
    private final ExamAnswerRepository answerRepo;
    private final QuestionOptionsRepository optionRepo;
    private final QuestionRepository questionRepo;
    private final UserRepository userRepository;

    private final ExamMapper examMapper;

    @Override
    public void submitAnswer(Long attemptId, Long questionId, Long optionId) {
        ExamAttempts attempt = attemptRepo.findById(attemptId).orElseThrow();
        QuestionOptions option = optionRepo.findById(optionId).orElseThrow();

        ExamAnswers answer = new ExamAnswers();
        answer.setExamAttempts(attempt);
        answer.setQuestions(option.getQuestions());
        answer.setQuestionOptions(option);
        answer.setIsCorrect(option.getCorrect());
        answerRepo.save(answer);
    }

    @Override
    public void submitEssay(Long attemptId, Long questionId, String answerText) {
        ExamAttempts attempt = attemptRepo.findById(attemptId).orElseThrow();
        Questions question = questionRepo.findById(questionId).orElseThrow();

        ExamAnswers answer = new ExamAnswers();
        answer.setExamAttempts(attempt);
        answer.setQuestions(question);
        answer.setAnswerText(answerText);
        answer.setIsCorrect(null); // chưa chấm

        answerRepo.save(answer);
    }

    @Override
    public ExamAttempts finishExam(Long attemptId) {
        ExamAttempts attempt = attemptRepo.findById(attemptId).orElseThrow();

        List<ExamAnswers> answers = answerRepo.findByExamAttempts_Id(attemptId);

        long correctCount = answers.stream()
                .filter(a -> Boolean.TRUE.equals(a.getIsCorrect()))
                .count();

        attempt.setScore(BigDecimal.valueOf(correctCount));
        attempt.setSubmitted(true);
        attempt.setEndTime(Timestamp.from(Instant.now()));

        return attemptRepo.save(attempt);
    }

    // @Override
    // public List<QuestionExamDto> getQuestionsForExam(Long examId, Long attemptId)
    // {
    // Exams exam = examRepository.findById(examId).orElseThrow();
    // List<ExamQuestions> eqs =
    // examQuestionRepo.findByExams_IdOrderByOrderingAsc(examId);
    // List<ExamAnswers> answers = answerRepo.findByExamAttempts_Id(attemptId);
    //
    // List<QuestionExamDto> dtos = eqs.stream().map(eq -> {
    // Questions q = eq.getQuestions();
    // List<QuestionOptions> options = optionRepo.findByQuestions_Id(q.getId());
    // ExamAnswers ans = answers.stream()
    // .filter(a -> a.getQuestions().getId() == q.getId())
    // .findFirst().orElse(null);
    //
    // String studentAnswer = null;
    // if (ans != null) {
    // studentAnswer = (ans.getQuestionOptions() != null)
    // ? String.valueOf(ans.getQuestionOptions().getId())
    // : ans.getAnswerText();
    //
    // }
    // return examMapper.toQuestionDto(q, options, studentAnswer);
    // }).collect(Collectors.toList());
    //
    // if (exam.isIsRandom())
    // Collections.shuffle(dtos);
    // return dtos;
    // }

    // @Override
    // public List<AnswerResultDto> getResultForAttempt(Long attemptId) {
    // ExamAttempts attempt = attemptRepo.findById(attemptId).orElseThrow();
    // List<ExamQuestions> eqs =
    // examQuestionRepo.findByExams_IdOrderByOrderingAsc(attempt.getExams().getId());
    // List<ExamAnswers> answers = answerRepo.findByExamAttempts_Id(attemptId);
    //
    // return eqs.stream().map(eq -> {
    // Questions q = eq.getQuestions();
    // ExamAnswers ans = answers.stream()
    // .filter(a -> a.getQuestions().getId() == q.getId())
    // .findFirst().orElse(null);
    // List<QuestionOptions> options = optionRepo.findByQuestions_Id(q.getId());
    // return examMapper.toAnswerResultDto(q, ans, options, eq.getPoints());
    // }).collect(Collectors.toList());
    // }

    @Override
    public ExamAttemptDto startExam(Long examId, Long studentId) {
        ExamAttempts attempt = new ExamAttempts();
        attempt.setExams(examRepository.findById(examId).orElseThrow());
        Students student = new Students();
        student.setId(studentId);
        attempt.setStudents(student);
        attempt.setStartTime(new Timestamp(System.currentTimeMillis()));
        attempt.setSubmitted(false);

        return examMapper.toDto(attemptRepo.save(attempt));
    }

    @Override
    public ExamDto createExam(ExamDto dto, UUID userId) {
        Exams exam = examMapper.toEntity(dto);

        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        exam.setUsers(user);
        exam.setStatus("DRAFT");
        exam.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        exam.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        Exams saved = examRepository.save(exam);
        return examMapper.toDto(saved);
    }

    @Override
    public List<ExamDto> getExamsByUserId(UUID userId, String sort) {
        List<Exams> exams = examRepository.findByUsers_Id(userId);

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
    public ExamDto updateExam(ExamDto dto, UUID userId) {
        Exams exam = examRepository.findById(dto.getId())
                .orElseThrow(() -> new RuntimeException("Exam not found"));

        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

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
}
