package com.example.qnuquiz.dto.exam;

import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamReviewDTO {

	private long examAttemptId;
	private String examTitle;
	private int score;
	private List<ExamAnswerReviewDTO> answers;
}
