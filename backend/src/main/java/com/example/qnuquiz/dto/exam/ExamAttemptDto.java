package com.example.qnuquiz.dto.exam;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;
@Data
@Builder
public class ExamAttemptDto {
	private long id;
	private long examId;
	private Timestamp startTime;
	private boolean submit;
}
