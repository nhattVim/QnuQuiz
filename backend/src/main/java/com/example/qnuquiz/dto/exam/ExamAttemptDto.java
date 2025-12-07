package com.example.qnuquiz.dto.exam;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamAttemptDto {
	private long id;
	private long examId;
	private Timestamp startTime;
	private boolean submit;
}
