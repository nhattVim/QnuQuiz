package com.example.qnuquiz.service.impl;

import com.example.qnuquiz.dto.analytics.*;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.repository.*;
import com.example.qnuquiz.service.AnalyticsService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AnalyticsServiceIml implements AnalyticsService {

    private final ExamAttemptRepository examAttemptRepository;
    private final UserRepository userRepository;
    private final ExamRepository examRepository;
    private final QuestionRepository questionRepository;
    private final QuestionOptionsRepository questionOptionsRepository;

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public List<RankingDto> rankingAll() {
        return examAttemptRepository.rankingAll();
    }

    @Override
    public List<RankingDto> rankingAllThisWeek() {
        LocalDate today = LocalDate.now();
        LocalDate monday = today.with(DayOfWeek.MONDAY);
        LocalDateTime mondayStart = monday.atStartOfDay();
        Timestamp fromDate = Timestamp.valueOf(mondayStart);
        return examAttemptRepository.rankingAllThisWeek(fromDate);
    }

    @Override
    public List<RankingDto> rankingByExamId(Long examId) {
        return examAttemptRepository.rankingByExamId(examId);
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<ExamAnalyticsDto> getExamAnalytics(String teacherId) {
        String sql = "SELECT e.id AS exam_id, e.title AS exam_title, " +
                "COUNT(ea.id) AS total_attempts, " +
                "COUNT(ea.id) FILTER (WHERE ea.submitted = TRUE) AS total_submitted, " +
                "CAST(ROUND(AVG(ea.score) FILTER (WHERE ea.submitted = TRUE), 2) AS double precision) AS avg_score, " +
                "CAST(MAX(ea.score) FILTER (WHERE ea.submitted = TRUE) AS double precision) AS max_score, " +
                "CAST(MIN(ea.score) FILTER (WHERE ea.submitted = TRUE) AS double precision) AS min_score " +
                "FROM exams e LEFT JOIN exam_attempts ea ON e.id = ea.exam_id " +
                "WHERE e.created_by = :teacherId " +
                "GROUP BY e.id, e.title ORDER BY e.created_at DESC";
        Query query = entityManager.createNativeQuery(sql, "ExamAnalyticsDtoMapping");
        query.setParameter("teacherId", UUID.fromString(teacherId));
        return query.getResultList();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<ClassPerformanceDto> getClassPerformance(Long examId) {
        String sql = "SELECT c.name AS class_name, COUNT(DISTINCT s.id) AS student_count, " +
                "CAST(ROUND(AVG(ea.score), 2) AS double precision) AS avg_score_per_class " +
                "FROM exam_attempts ea JOIN students s ON ea.student_id = s.id " +
                "JOIN classes c ON s.class_id = c.id " +
                "WHERE ea.exam_id = :examId AND ea.submitted = TRUE " +
                "GROUP BY c.name ORDER BY avg_score_per_class DESC";
        Query query = entityManager.createNativeQuery(sql, "ClassPerformanceDtoMapping");
        query.setParameter("examId", examId);
        return query.getResultList();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<ScoreDistributionDto> getScoreDistribution(String teacherId) {

        String sql = "WITH exam_total_points AS ( " +
                "    SELECT e.id AS exam_id, " +
                "           CASE WHEN e.max_questions IS NOT NULL THEN e.max_questions * 10" +
                "                ELSE (COUNT(q.id) * 10) END AS total_points " +
                "    FROM exams e " +
                "    LEFT JOIN questions q ON q.exam_id = e.id " +
                "    GROUP BY e.id, e.max_questions " +
                ") " +
                "SELECT e.title, " +
                "       COUNT(ea.id) FILTER (WHERE (ea.score * 100.0 / etp.total_points) >= 90) AS excellent_count, " +
                "       COUNT(ea.id) FILTER (WHERE (ea.score * 100.0 / etp.total_points) >= 70 " +
                "                           AND (ea.score * 100.0 / etp.total_points) < 90) AS good_count, " +
                "       COUNT(ea.id) FILTER (WHERE (ea.score * 100.0 / etp.total_points) >= 50 " +
                "                           AND (ea.score * 100.0 / etp.total_points) < 70) AS average_count, " +
                "       COUNT(ea.id) FILTER (WHERE (ea.score * 100.0 / etp.total_points) < 50) AS fail_count " +
                "FROM exams e " +
                "JOIN exam_attempts ea ON e.id = ea.exam_id " +
                "JOIN exam_total_points etp ON etp.exam_id = e.id " +
                "WHERE e.created_by = :teacherId " +
                "  AND ea.submitted = TRUE " +
                "GROUP BY e.id, e.title, etp.total_points";
        Query query = entityManager.createNativeQuery(sql, "ScoreDistributionDtoMapping");
        query.setParameter("teacherId", UUID.fromString(teacherId));
        return query.getResultList();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<StudentAttemptDto> getStudentAttempts(Long examId) {
        String sql = "SELECT s.student_code, u.full_name, c.name AS class_name, ea.start_time, ea.end_time, " +
                "ROUND(EXTRACT(EPOCH FROM (ea.end_time - ea.start_time))/60, 2) AS duration_minutes, " +
                "CAST(ea.score AS double precision) AS score, ea.submitted " +
                "FROM exam_attempts ea JOIN students s ON ea.student_id = s.id " +
                "JOIN users u ON s.user_id = u.id " +
                "LEFT JOIN classes c ON s.class_id = c.id " +
                "WHERE ea.exam_id = :examId ORDER BY ea.score DESC, ea.end_time ASC";
        Query query = entityManager.createNativeQuery(sql, "StudentAttemptDtoMapping");
        query.setParameter("examId", examId);
        return query.getResultList();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<QuestionAnalyticsDto> getQuestionAnalytics(Long examId) {
        String sql = "SELECT q.content AS question_content, COUNT(ans.id) AS total_answers, " +
                "COUNT(ans.id) FILTER (WHERE ans.is_correct = TRUE) AS correct_count, " +
                "COUNT(ans.id) FILTER (WHERE ans.is_correct = FALSE) AS wrong_count, " +
                "CAST(ROUND((COUNT(ans.id) FILTER (WHERE ans.is_correct = TRUE)::DECIMAL / COUNT(ans.id)) * 100, 2) AS double precision) AS correct_rate "
                +
                "FROM exam_answers ans JOIN questions q ON ans.question_id = q.id " +
                "WHERE q.exam_id = :examId GROUP BY q.id, q.content ORDER BY correct_rate ASC";
        Query query = entityManager.createNativeQuery(sql, "QuestionAnalyticsDtoMapping");
        query.setParameter("examId", examId);
        return query.getResultList();
    }

    @Override
    public UserAnalyticsDto getUserAnalytics() {
        long totalUsers = userRepository.count();

        Timestamp thirtyDaysAgo = Timestamp.from(Instant.now().minus(30, ChronoUnit.DAYS));
        long newUsersThisMonth = userRepository.countByCreatedAtAfter(thirtyDaysAgo);

        long studentsCount = userRepository.countByRole("STUDENT");
        long teachersCount = userRepository.countByRole("TEACHER");
        long adminCount = userRepository.countByRole("ADMIN");

        return UserAnalyticsDto.builder()
                .totalUsers(totalUsers)
                .newUsersThisMonth(newUsersThisMonth)
                .activeUsers(totalUsers) // For now, consider all users active
                .studentsCount(studentsCount)
                .teachersCount(teachersCount)
                .adminCount(adminCount)
                .build();
    }

    @Override
    public AdminExamAnalyticsDto getExamAnalyticsAdmin() {
        long totalExams = examRepository.count();

        // Assuming an exam is active if its end time is in the future or it has no end
        // time and start time is in past
        long activeExams = examRepository.findAll().stream()
                .filter(exam -> exam.getEndTime() == null || exam.getEndTime().after(Timestamp.from(Instant.now())))
                .filter(exam -> exam.getStartTime() == null
                        || exam.getStartTime().before(Timestamp.from(Instant.now())))
                .count();

        long totalQuestions = questionRepository.count();
        List<Exams> allExams = examRepository.findAll();
        double averageQuestionsPerExam = allExams.isEmpty() ? 0 : (double) totalQuestions / allExams.size();

        long totalAttempts = examAttemptRepository.count();
        double averageAttemptsPerExam = allExams.isEmpty() ? 0 : (double) totalAttempts / allExams.size();

        Double overallAverageScore = examAttemptRepository.findAverageScoreOverall();

        return AdminExamAnalyticsDto.builder()
                .totalExams(totalExams)
                .activeExams(activeExams)
                .averageQuestionsPerExam(averageQuestionsPerExam)
                .averageAttemptsPerExam(averageAttemptsPerExam)
                .overallAverageScore(overallAverageScore != null ? overallAverageScore : 0.0)
                .build();
    }

    @Override
    public AdminQuestionAnalyticsDto getQuestionAnalyticsAdmin() {
        long totalQuestions = questionRepository.count();

        long multipleChoiceQuestions = questionRepository.countByType("MULTIPLE_CHOICE");
        long trueFalseQuestions = questionRepository.countByType("TRUE_FALSE"); // Assuming TRUE_FALSE as another type

        long totalOptions = questionOptionsRepository.count();
        double averageOptionsPerQuestion = totalQuestions == 0 ? 0 : (double) totalOptions / totalQuestions;

        // This would require a more complex query to count how many times each question
        // appears in exam_attempts
        // For simplicity, we'll assume each question is used at least once in an exam.
        double averageUsageInExams = totalQuestions == 0 ? 0
                : (double) examAttemptRepository.countDistinctExamsWithQuestions() / totalQuestions;

        return AdminQuestionAnalyticsDto.builder()
                .totalQuestions(totalQuestions)
                .multipleChoiceQuestions(multipleChoiceQuestions)
                .trueFalseQuestions(trueFalseQuestions)
                .averageOptionsPerQuestion(averageOptionsPerQuestion)
                .averageUsageInExams(averageUsageInExams)
                .build();
    }
}
