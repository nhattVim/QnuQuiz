package com.example.qnuquiz.controller;

import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Collections;
import java.util.List;

import org.hamcrest.Matchers;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.example.qnuquiz.config.SecurityConfig;
import com.example.qnuquiz.dto.exam.ExamAnswerReviewDTO;
import com.example.qnuquiz.dto.exam.ExamAttemptDto;
import com.example.qnuquiz.dto.exam.ExamCategoryDto;
import com.example.qnuquiz.dto.exam.ExamDto;
import com.example.qnuquiz.dto.exam.ExamResultDto;
import com.example.qnuquiz.dto.exam.ExamReviewDTO;
import com.example.qnuquiz.dto.exam.QuestionDTO;
import com.example.qnuquiz.dto.exam.QuestionOptionDTO;
import com.example.qnuquiz.security.CustomUserDetailsService;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.ExamService;

import jakarta.persistence.EntityNotFoundException;

@WebMvcTest(ExamController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import({TestExceptionHandler.class, SecurityConfig.class})

class ExamControllerTest extends BaseTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private CustomUserDetailsService customUserDetailsService;
    @MockitoBean
    private ExamService examService; // 👈 thay cho @MockBean

    @Test
    void testStartExamSuccess() throws Exception {
        long examId = 1;
        long attemptId = 129;
        Timestamp startTime = Timestamp.from(Instant.parse("2025-11-27T01:31:43.050+00:00"));

        ExamAttemptDto attemptDto = new ExamAttemptDto(attemptId, examId, startTime, false);
        given(examService.startExam(examId)).willReturn(attemptDto);

        mockMvc.perform(post("/api/exams/{examId}/start", examId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(attemptId))
                .andExpect(jsonPath("$.examId").value(examId))
                .andExpect(jsonPath("$.startTime").value(Matchers.anyOf(
                	    Matchers.equalTo("2025-11-27T01:31:43.050Z"),
                	    Matchers.equalTo("2025-11-27T01:31:43.050+00:00")
                	)))
                .andExpect(jsonPath("$.submit").value(false));
    }
    
    // 2. Exam không tồn tại
    @Test
    void testStartExamNotFound() throws Exception {
        long examId = 93;

        doThrow(new EntityNotFoundException("Exam not found"))
                .when(examService).startExam(examId);

        mockMvc.perform(post("/api/exams/{examId}/start", examId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }


    @Test
    void testSubmitAnswerSuccess() throws Exception {
        long attemptId = 1L;
        long questionId = 10L;
        long optionId = 100L;

        // mock service không throw exception
        doNothing().when(examService).submitAnswer(attemptId, questionId, optionId);

        mockMvc.perform(post("/api/exams/{attemptId}/answer/{questionId}/{optionId}",
                             attemptId, questionId, optionId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }

    @Test
    void testSubmitAnswerNotFound() throws Exception {
        long attemptId = 999L;
        long questionId = 10L;
        long optionId = 100L;

        // Giả lập service ném EntityNotFoundException
        doThrow(new EntityNotFoundException("Attempt or question not found"))
                .when(examService).submitAnswer(attemptId, questionId, optionId);

        mockMvc.perform(post("/api/exams/{attemptId}/answer/{questionId}/{optionId}",
                             attemptId, questionId, optionId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Attempt or question not found"));
    }

    
    @Test
    @WithMockUser(roles = "STUDENT")
    void testFinishExamSuccess() throws Exception {
        long attemptId = 1L;

        ExamResultDto resultDto = ExamResultDto.builder()
                .score(85)
                .correctCount(17)
                .totalQuestions(20)
                .build();

        given(examService.finishExam(attemptId)).willReturn(resultDto);

        mockMvc.perform(post("/api/exams/{attemptId}/finish", attemptId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.score").value(85))
                .andExpect(jsonPath("$.correctCount").value(17))
                .andExpect(jsonPath("$.totalQuestions").value(20));
    }
    
    @Test
    @WithMockUser(roles = "STUDENT")
    void testFinishExamNotFound() throws Exception {
        long attemptId = 999L;

        doThrow(new EntityNotFoundException("Exam attempt not found"))
                .when(examService).finishExam(attemptId);

        mockMvc.perform(post("/api/exams/{attemptId}/finish", attemptId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Exam attempt not found"));
    }
    
    @Test
    void testGetQuestionsSuccess() throws Exception {
        long examId = 1L;

        List<QuestionDTO> questions = List.of(
                QuestionDTO.builder()
                        .id(10L)
                        .content("What is Java?")
                        .type("ESSAY")
                        .points(BigDecimal.valueOf(5))
                        .options(Collections.emptyList())
                        .build(),
                QuestionDTO.builder()
                        .id(11L)
                        .content("Which of the following are OOP concepts?")
                        .type("MULTIPLE_CHOICE")
                        .points(BigDecimal.valueOf(10))
                        .options(List.of(
                        		QuestionOptionDTO.builder().id(1L).content("Encapsulation").correct(true).build(),
                        		QuestionOptionDTO.builder().id(2L).content("Polymorphism").correct(true).build(),
                        		QuestionOptionDTO.builder().id(3L).content("Recursion").correct(false).build()
                        ))
                        .build()
        );

        given(examService.getQuestionsForExam(examId)).willReturn(questions);
        mockMvc.perform(get("/api/exams/{examId}/questions", examId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(10))
                .andExpect(jsonPath("$[0].content").value("What is Java?"))
                .andExpect(jsonPath("$[1].options[0].content").value("Encapsulation"))
                .andExpect(jsonPath("$[1].options[0].correct").value(true));
    }
    
    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetQuestionsNotFound() throws Exception {
        long examId = 999L;

        doThrow(new EntityNotFoundException("Exam not found"))
                .when(examService).getQuestionsForExam(examId);

        mockMvc.perform(get("/api/exams/{examId}/questions", examId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Exam not found"));
    }
    
    @Test
    void testReviewExamSuccess() throws Exception {
        long attemptId = 1L;

        ExamReviewDTO reviewDto = ExamReviewDTO.builder()
                .examAttemptId(attemptId)
                .examTitle("Java Basics")
                .score(85)
                .answers(List.of(
                        ExamAnswerReviewDTO.builder()
                                .questionId(10L)
                                .questionContent("What is Java?")
                                .type("ESSAY")
                                .studentAnswer("Java is a programming language")
                                .options(Collections.emptyList())
                                .correct(true)
                                .build(),
                        ExamAnswerReviewDTO.builder()
                                .questionId(11L)
                                .questionContent("OOP concepts?")
                                .type("MULTIPLE_CHOICE")
                                .studentAnswer("Encapsulation, Polymorphism")
                                .options(List.of(
                                		QuestionOptionDTO.builder().id(1L).content("Encapsulation").correct(true).build(),
                                		QuestionOptionDTO.builder().id(2L).content("Polymorphism").correct(true).build(),
                                		QuestionOptionDTO.builder().id(3L).content("Recursion").correct(false).build()
                                ))
                                .correct(true)
                                .build()
                ))
                .build();

        given(examService.reviewExamAttempt(attemptId)).willReturn(reviewDto);

        mockMvc.perform(get("/api/exams/attempts/{attemptId}/review", attemptId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.examAttemptId").value(attemptId))
                .andExpect(jsonPath("$.examTitle").value("Java Basics"))
                .andExpect(jsonPath("$.score").value(85))
                .andExpect(jsonPath("$.answers[0].questionContent").value("What is Java?"))
                .andExpect(jsonPath("$.answers[1].options[0].content").value("Encapsulation"))
                .andExpect(jsonPath("$.answers[1].options[0].correct").value(true));
    }

    
    @Test
    void testReviewExamNotFound() throws Exception {
        long attemptId = 999L;

        doThrow(new EntityNotFoundException("Exam attempt not found"))
                .when(examService).reviewExamAttempt(attemptId);

        mockMvc.perform(get("/api/exams/attempts/{attemptId}/review", attemptId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Exam attempt not found"));
    }


    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetLatestAttemptSuccess() throws Exception {
        long examId = 1L;
        ExamAttemptDto attemptDto = new ExamAttemptDto(100L, examId, Timestamp.from(Instant.now()), false);

        given(examService.getLatestAttempt(examId)).willReturn(attemptDto);

        mockMvc.perform(get("/api/exams/{examId}/latest-attempt", examId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(100))
                .andExpect(jsonPath("$.examId").value(examId));
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetLatestAttemptNotFound() throws Exception {
        long examId = 999L;

        doThrow(new EntityNotFoundException("Exam not found"))
                .when(examService).getLatestAttempt(examId);

        mockMvc.perform(get("/api/exams/{examId}/latest-attempt", examId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Exam not found"));
    }
    
    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetAllCategoriesSuccess() throws Exception {
        List<ExamCategoryDto> categories = List.of(
                ExamCategoryDto.builder().id(1L).name("Programming").totalExams(5L).build(),
                ExamCategoryDto.builder().id(2L).name("Math").totalExams(3L).build()
        );

        given(examService.getAllCategories()).willReturn(categories);

        mockMvc.perform(get("/api/exams/categories")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].name").value("Programming"))
                .andExpect(jsonPath("$[0].totalExams").value(5))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[1].name").value("Math"))
                .andExpect(jsonPath("$[1].totalExams").value(3));
    }
    
    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetExamsByCategorySuccess() throws Exception {
        long categoryId = 1L;
        List<ExamDto> exams = List.of(
                ExamDto.builder().id(10L).title("Java Basics").description("Intro exam").build(),
                ExamDto.builder().id(11L).title("Spring Boot").description("Advanced exam").build()
        );

        given(examService.getExamsByCategory(categoryId)).willReturn(exams);

        mockMvc.perform(get("/api/exams/categories/{categoryId}", categoryId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("Java Basics"))
                .andExpect(jsonPath("$[1].title").value("Spring Boot"));
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetExamsByCategoryNotFound() throws Exception {
        long categoryId = 999L;

        doThrow(new EntityNotFoundException("Category not found"))
                .when(examService).getExamsByCategory(categoryId);

        mockMvc.perform(get("/api/exams/categories/{categoryId}", categoryId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Category not found"));
    }
    
    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetAllExamsSuccess() throws Exception {
        List<ExamDto> exams = List.of(
                ExamDto.builder().id(10L).title("Java Basics").description("Intro exam").build(),
                ExamDto.builder().id(11L).title("Spring Boot").description("Advanced exam").build()
        );

        given(examService.getAllExams()).willReturn(exams);

        mockMvc.perform(get("/api/exams/getAll")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("Java Basics"))
                .andExpect(jsonPath("$[1].title").value("Spring Boot"));
    }
    
    

}