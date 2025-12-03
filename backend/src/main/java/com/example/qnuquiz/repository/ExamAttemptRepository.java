package com.example.qnuquiz.repository;

import java.sql.Timestamp;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.example.qnuquiz.dto.analytics.RankingDto;
import com.example.qnuquiz.entity.ExamAttempts;

@Repository
public interface ExamAttemptRepository extends JpaRepository<ExamAttempts, Long> {

	List<ExamAttempts> findByExamsId(Long id);

	List<ExamAttempts> findByStudentsIdAndSubmittedTrueOrderByEndTimeDesc(Long studentId);

	List<ExamAttempts> findByExamsIdAndStudentsIdAndSubmittedFalseOrderByCreatedAtDesc(Long examId, Long studentId);

	List<ExamAttempts> findByExamsIdAndStudentsIdOrderByCreatedAtDesc(Long examId, Long studentId);

	List<ExamAttempts> findByStudents_IdOrderByEndTimeDesc(Long studentId);

	@Query("""
			    SELECT new com.example.qnuquiz.dto.analytics.RankingDto(
			        u.username,
			 				COALESCE(SUM(ea.score), 0),
			        u.fullName,
			        COALESCE(u.avatarUrl, 'https://i.pinimg.com/736x/8f/1c/a2/8f1ca2029e2efceebd22fa05cca423d7.jpg')
			    )
			    FROM ExamAttempts ea
			    JOIN ea.students s
			    JOIN s.users u
			    GROUP BY u.username, u.fullName, u.avatarUrl
			    ORDER BY SUM(ea.score) DESC
			""")
	List<RankingDto> rankingAll();

	@Query("""
			    SELECT new com.example.qnuquiz.dto.analytics.RankingDto(
			        u.username,
			 				COALESCE(SUM(ea.score), 0),
			        u.fullName,
			        COALESCE(u.avatarUrl, 'https://i.pinimg.com/736x/8f/1c/a2/8f1ca2029e2efceebd22fa05cca423d7.jpg')
			    )
			    FROM ExamAttempts ea
			    JOIN ea.students s
			    JOIN s.users u
			    WHERE ea.createdAt >= :fromDate
			    GROUP BY u.username, u.fullName, u.avatarUrl
			    ORDER BY SUM(ea.score) DESC
			""")
	List<RankingDto> rankingAllThisWeek(Timestamp fromDate);

	@Query("""
			    SELECT new com.example.qnuquiz.dto.analytics.RankingDto(
			        u.username,
			 				COALESCE(SUM(ea.score), 0),
			        u.fullName,
			        COALESCE(u.avatarUrl, 'https://i.pinimg.com/736x/8f/1c/a2/8f1ca2029e2efceebd22fa05cca423d7.jpg')
			    )
			    FROM ExamAttempts ea
			    JOIN ea.students s
			    JOIN s.users u
				WHERE ea.exams.id = :examId
			    GROUP BY u.username, u.fullName, u.avatarUrl
			    ORDER BY SUM(ea.score) DESC
			""")
	List<RankingDto> rankingByExamId(Long examId);
}
