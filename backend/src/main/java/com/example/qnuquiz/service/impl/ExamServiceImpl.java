package com.example.qnuquiz.service.impl;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamCreateDto;
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
        answer.setIsCorrect(option.isIsCorrect());
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
    public ExamCreateDto createExam(ExamCreateDto dto) {
        Exams exam = examMapper.toEntity(dto);

        Users user = userRepository.findById(UUID.fromString(dto.getUserId()))
                .orElseThrow(() -> new RuntimeException("User not found"));

        exam.setUsers(user);
        exam.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        exam.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        Exams saved = examRepository.save(exam);
        return examMapper.toCreateDto(saved);
    }
}
