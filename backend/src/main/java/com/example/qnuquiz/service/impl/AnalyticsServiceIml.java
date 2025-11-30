package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.analytics.ClassPerformanceDto;
import com.example.qnuquiz.dto.analytics.ExamAnalyticsDto;
import com.example.qnuquiz.dto.analytics.QuestionAnalyticsDto;
import com.example.qnuquiz.dto.analytics.RankingDto;
import com.example.qnuquiz.dto.analytics.ScoreDistributionDto;
import com.example.qnuquiz.dto.analytics.StudentAttemptDto;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.service.AnalyticsService;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class AnalyticsServiceIml implements AnalyticsService {

    private final ExamAttemptRepository examAttemptRepository;

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public List<RankingDto> rankingAll() {
        return examAttemptRepository.rankingAll();
    }

    @Override
    public List<RankingDto> rankingAllThisWeek() {
        Timestamp weekAgo = new Timestamp(System.currentTimeMillis() - 7L * 86400 * 1000);
        return examAttemptRepository.rankingAllThisWeek(weekAgo);
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

    // @Override
    // @SuppressWarnings("unchecked")
    // public List<ScoreDistributionDto> getScoreDistribution(String teacherId) {
    // String sql = "SELECT e.title, " +
    // "COUNT(ea.id) FILTER (WHERE ea.score >= 9) AS excellent_count, " +
    // "COUNT(ea.id) FILTER (WHERE ea.score >= 7 AND ea.score < 9) AS good_count, "
    // +
    // "COUNT(ea.id) FILTER (WHERE ea.score >= 5 AND ea.score < 7) AS average_count,
    // " +
    // "COUNT(ea.id) FILTER (WHERE ea.score < 5) AS fail_count " +
    // "FROM exams e JOIN exam_attempts ea ON e.id = ea.exam_id " +
    // "WHERE e.created_by = :teacherId AND ea.submitted = TRUE " +
    // "GROUP BY e.id, e.title";
    // Query query = entityManager.createNativeQuery(sql,
    // "ScoreDistributionDtoMapping");
    // query.setParameter("teacherId", UUID.fromString(teacherId));
    // return query.getResultList();
    // }

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
}
