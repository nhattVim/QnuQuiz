package com.eample.exam;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.mapper.ExamMapper;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.service.impl.ExamServiceImpl;

@ExtendWith(MockitoExtension.class)
public class GetExamTest {


    @Mock
    private ExamRepository examRepository;

    @Mock
    private ExamMapper examMapper;

    @InjectMocks
    private ExamServiceImpl examService;

    @Test
    public void testGetAllExams_success() {
        // Mock dữ liệu từ DB
        Exams exam1 = new Exams();
        exam1.setId(1L);
        exam1.setTitle("Math Final");

        Exams exam2 = new Exams();
        exam2.setId(2L);
        exam2.setTitle("Physics Midterm");

        List<Exams> examEntities = Arrays.asList(exam1, exam2);

        // Mock dữ liệu DTO trả về
        ExamDto dto1 = ExamDto.builder()
                .id(1L)
                .title("Math Final")
                .build();

        ExamDto dto2 = ExamDto.builder()
                .id(2L)
                .title("Physics Midterm")
                .build();

        List<ExamDto> expectedDtos = Arrays.asList(dto1, dto2);

        // Khi gọi repository và mapper
        when(examRepository.findAll()).thenReturn(examEntities);
        when(examMapper.toDtoList(examEntities)).thenReturn(expectedDtos);

        // Gọi service
        List<ExamDto> result = examService.getAllExams();

        // Kiểm tra kết quả
        assertEquals(2, result.size());
        assertEquals("Math Final", result.get(0).getTitle());
        assertEquals("Physics Midterm", result.get(1).getTitle());

        verify(examRepository).findAll();
        verify(examMapper).toDtoList(examEntities);
    }



}
