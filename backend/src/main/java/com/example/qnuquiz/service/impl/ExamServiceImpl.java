package com.example.qnuquiz.service.impl;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.ExamQuestions;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.repository.ExamAnswerRepository;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.repository.ExamQuestionRepository;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.QuestionOptionsRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.service.ExamService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class ExamServiceImpl implements ExamService {

    private final ExamRepository examRepo;
    private final ExamAttemptRepository attemptRepo;
    private final ExamAnswerRepository answerRepo;
    private final QuestionOptionsRepository optionRepo;
    private final QuestionRepository questionRepo;
    private final ExamQuestionRepository examQuestionRepo;



    @Override
    public ExamAttempts startExam(Long examId, Long studentId) {
        ExamAttempts attempt = new ExamAttempts();
        attempt.setExams(examRepo.findById(examId).orElseThrow());
        Students student = new Students();
        student.setId(studentId);
        attempt.setStudents(student);
        attempt.setStartTime(new Timestamp(System.currentTimeMillis()));
        attempt.setSubmitted(false);
        
        return attemptRepo.save(attempt);
    }
	
    @Override
    public ExamAnswers submitAnswer(Long attemptId, Long questionId, Long optionId) {
        ExamAttempts attempt = attemptRepo.findById(attemptId).orElseThrow();
        QuestionOptions option = optionRepo.findById(optionId).orElseThrow();

        ExamAnswers answer = new ExamAnswers();
        answer.setExamAttempts(attempt);
        answer.setQuestions(option.getQuestions());
        answer.setQuestionOptions(option);
        answer.setIsCorrect(option.isIsCorrect());

        return answerRepo.save(answer);
    }
    @Override
    public ExamAnswers submitEssay(Long attemptId, Long questionId, String answerText) {
        ExamAttempts attempt = attemptRepo.findById(attemptId).orElseThrow();
        Questions question = questionRepo.findById(questionId).orElseThrow();

        ExamAnswers answer = new ExamAnswers();
        answer.setExamAttempts(attempt);
        answer.setQuestions(question);
        answer.setAnswerText(answerText);
        answer.setIsCorrect(null); // chưa chấm

        return answerRepo.save(answer);
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

    public List<Questions> getQuestionsForExam(Long examId) {
        Exams exam = examRepo.findById(examId).orElseThrow();
        List<ExamQuestions> eqs = examQuestionRepo.findByExams_IdOrderByOrderingAsc(examId);
        List<Questions> questions = eqs.stream()
                                       .map(ExamQuestions::getQuestions)
                                       .collect(Collectors.toList());

        if (exam.isIsRandom()) {
            Collections.shuffle(questions);
        }

        return questions;
    }

    
}
