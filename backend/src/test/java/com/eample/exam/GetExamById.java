package com.eample.exam;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

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
public class GetExamById {
	   @Mock
	    private ExamRepository examRepository;

	    @Mock
	    private ExamMapper examMapper;

	    @InjectMocks
	    private ExamServiceImpl examService;

	    @Test
	    public void testGetExamsByUserId_sortedAsc() {
	        UUID userId = UUID.randomUUID();

	        Exams exam1 = new Exams();
	        exam1.setId(1L);
	        exam1.setTitle("Math");
	        exam1.setCreatedAt(Timestamp.valueOf("2023-01-01 10:00:00"));

	        Exams exam2 = new Exams();
	        exam2.setId(2L);
	        exam2.setTitle("Physics");
	        exam2.setCreatedAt(Timestamp.valueOf("2023-02-01 10:00:00"));

	        List<Exams> exams = Arrays.asList(exam2, exam1); // intentionally out of order

	        ExamDto dto1 = ExamDto.builder().id(1L).title("Math").status("ACTIVE").build();
	        ExamDto dto2 = ExamDto.builder().id(2L).title("Physics").status("ACTIVE").build();

	        when(examRepository.findByUsers_Id(userId)).thenReturn(exams);
	        when(examMapper.toDto(exam1)).thenReturn(dto1);
	        when(examMapper.toDto(exam2)).thenReturn(dto2);

	        List<ExamDto> result = examService.getExamsByUserId(userId, "asc");

	        assertEquals(2, result.size());
	        assertEquals("Math", result.get(0).getTitle()); // exam1 should come first
	        assertEquals("Physics", result.get(1).getTitle());
	    }


}
