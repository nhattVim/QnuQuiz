package com.example.qnuquiz.dto.exam;

import java.sql.Timestamp;

import lombok.Builder;
import lombok.Data;
@Data
@Builder
public class ExamAttemptDto {
	private Timestamp startTime;
	private boolean submit;
}
