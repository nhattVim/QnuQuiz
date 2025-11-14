package com.example.qnuquiz.dto.student;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamHistoryDto {
    private Long attemptId;
    private Long examId;
    private String examTitle;
    private String examDescription;
    private BigDecimal score;
    private Timestamp completionDate; // end_time - ngày hoàn thành bài thi
    private Long durationMinutes; // Tổng thời gian làm bài (tính từ start_time đến end_time)
    private List<ExamAnswerHistoryDto> answers; // Danh sách đáp án
}

