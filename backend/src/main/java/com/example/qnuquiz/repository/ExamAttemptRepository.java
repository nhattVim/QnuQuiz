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

	List<ExamAttempts> findByStudents_IdOrderByEndTimeDesc(Long studentId);

	@Query("""
			    SELECT new com.example.qnuquiz.dto.analytics.RankingDto(
			        u.username,
			        SUM(ea.score),
			        u.fullName,
			        COALESCE(mf.fileUrl, 'https://i.pinimg.com/736x/8f/1c/a2/8f1ca2029e2efceebd22fa05cca423d7.jpg')
			    )
			    FROM ExamAttempts ea
			    JOIN ea.students s
			    JOIN s.users u
			    LEFT JOIN u.mediaFiles mf
			    GROUP BY u.username, u.fullName, mf.fileUrl
			    ORDER BY SUM(ea.score) DESC
			""")
	List<RankingDto> rankingAll();

	@Query("""
			    SELECT new com.example.qnuquiz.dto.analytics.RankingDto(
			        u.username,
			        SUM(ea.score),
			        u.fullName,
			        COALESCE(mf.fileUrl, 'https://i.pinimg.com/736x/8f/1c/a2/8f1ca2029e2efceebd22fa05cca423d7.jpg')
			    )
			    FROM ExamAttempts ea
			    JOIN ea.students s
			    JOIN s.users u
			    LEFT JOIN u.mediaFiles mf
			    WHERE ea.createdAt >= :fromDate
			    GROUP BY u.username, u.fullName, mf.fileUrl
			    ORDER BY SUM(ea.score) DESC
			""")
	List<RankingDto> rankingAllThisWeek(Timestamp fromDate);
}
