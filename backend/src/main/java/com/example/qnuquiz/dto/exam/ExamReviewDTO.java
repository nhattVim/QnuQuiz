package com.example.qnuquiz.dto.exam;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor 
@AllArgsConstructor
public class ExamReviewDTO {

	private long examAttemptId;
	private String examTitle;
	private int score;
	private List<ExamAnswerReviewDTO> answers;
}
