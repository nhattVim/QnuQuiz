package com.eample.exam;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.sql.Timestamp;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.ExamMapper;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.service.impl.ExamServiceImpl;

@ExtendWith(MockitoExtension.class)
public class CreateExamTest {

    @Mock
    private ExamRepository examRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ExamMapper examMapper;

    @InjectMocks
    private ExamServiceImpl examService;

    @Test
    public void testCreateExam_success() {
        UUID userId = UUID.randomUUID();

        ExamDto inputDto = ExamDto.builder()
                .title("Math Final")
                .description("Final exam for grade 12")
                .startTime(new Timestamp(System.currentTimeMillis()))
                .endTime(new Timestamp(System.currentTimeMillis() + 3600000)) // +1h
                .random(true)
                .durationMinutes(60)
                .status("ACTIVE")
                .build();

        Exams examEntity = new Exams(); // bạn có thể dùng builder nếu có
        Exams savedExam = new Exams();
        ExamDto outputDto = ExamDto.builder()
                .id(1L)
                .title("Math Final")
                .description("Final exam for grade 12")
                .startTime(inputDto.getStartTime())
                .endTime(inputDto.getEndTime())
                .random(true)
                .durationMinutes(60)
                .status("ACTIVE")
                .build();

        Users user = new Users();
        user.setId(userId);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(examMapper.toEntity(inputDto)).thenReturn(examEntity);
        when(examRepository.save(any(Exams.class))).thenReturn(savedExam);
        when(examMapper.toDto(savedExam)).thenReturn(outputDto);

        ExamDto result = examService.createExam(inputDto, userId);

        assertEquals(outputDto, result);
        verify(userRepository).findById(userId);
        verify(examRepository).save(any(Exams.class));
    }

    @Test
    public void testCreateExam_userNotFound() {
        UUID userId = UUID.randomUUID();

        ExamDto inputDto = ExamDto.builder()
                .title("Physics Midterm")
                .build();

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> examService.createExam(inputDto, userId));
    }
}
