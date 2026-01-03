package com.example.qnuquiz.controller;

import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.example.qnuquiz.dto.student.ExamAnswerHistoryDto;
import com.example.qnuquiz.dto.student.ExamHistoryDto;
import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.exception.GlobalExceptionHandler;
import com.example.qnuquiz.security.CustomUserDetailsService;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.StudentService;
import com.fasterxml.jackson.databind.ObjectMapper;


@WebMvcTest(StudentController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class StudentControllerTest extends BaseTest {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private CustomUserDetailsService customUserDetailsService;

    @MockitoBean
    private StudentService studentService;

    @BeforeEach
    void setup() {
        setupSecurityContext("student", "password", "ROLE_STUDENT");
    }

    /**
     Test cập nhật thông tin cá nhân thành công (STUDENT)
     */
    @Test
    @WithMockUser(roles = "STUDENT")
    void testUpdateCurrentStudentProfileSuccess() throws Exception {
        StudentDto requestDto = StudentDto.builder()
                .id(1L)
                .username("student1")
                .fullName("Student Updated")
                .email("student@example.com")
                .phoneNumber("0987654321")
                .departmentId(1L)
                .classId(1L)
                .build();

        StudentDto updatedDto = StudentDto.builder()
                .id(1L)
                .username("student1")
                .fullName("Student Updated")
                .email("student@example.com")
                .phoneNumber("0987654321")
                .departmentId(1L)
                .classId(1L)
                .build();

        given(studentService.updateCurrentStudentProfile(requestDto)).willReturn(updatedDto);

        mockMvc.perform(put("/api/students/me/profile")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.fullName").value("Student Updated"))
                .andExpect(jsonPath("$.email").value("student@example.com"))
                .andExpect(jsonPath("$.phoneNumber").value("0987654321"))
                .andExpect(jsonPath("$.departmentId").value(1))
                .andExpect(jsonPath("$.classId").value(1));
    }

    /**
     Test cập nhật thông tin cá nhân thất bại khi dữ liệu không hợp lệ
     */
    @Test
    @WithMockUser(roles = "STUDENT")
    void testUpdateCurrentStudentProfileInvalidData() throws Exception {
        StudentDto invalidDto = StudentDto.builder()
                .fullName("")
                .email("")
                .phoneNumber("")
                .build();

        doThrow(new RuntimeException("Vui lòng điền đầy đủ thông tin họ tên, email và số điện thoại"))
                .when(studentService).updateCurrentStudentProfile(invalidDto);

        mockMvc.perform(put("/api/students/me/profile")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidDto)))
                .andExpect(status().isInternalServerError());
    }

    /**
     Test xem lịch sử làm bài thành công
     */
    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetExamHistorySuccess() throws Exception {
        Timestamp completionDate = Timestamp.from(Instant.now());
        ExamHistoryDto history1 = ExamHistoryDto.builder()
                .attemptId(1L)
                .examId(100L)
                .examTitle("Java Basics Quiz")
                .examDescription("Basic Java concepts")
                .score(85)
                .completionDate(completionDate)
                .durationMinutes(30L)
                .answers(List.of(
                        ExamAnswerHistoryDto.builder()
                                .questionId(1L)
                                .questionContent("What is Java?")
                                .isCorrect(true)
                                .answerText("A programming language")
                                .build()
                ))
                .build();

        ExamHistoryDto history2 = ExamHistoryDto.builder()
                .attemptId(2L)
                .examId(101L)
                .examTitle("Spring Boot Quiz")
                .examDescription("Spring Boot concepts")
                .score(90)
                .completionDate(completionDate)
                .durationMinutes(45L)
                .answers(List.of())
                .build();

        given(studentService.getExamHistory()).willReturn(List.of(history1, history2));

        mockMvc.perform(get("/api/students/me/exam-history")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].attemptId").value(1))
                .andExpect(jsonPath("$[0].examTitle").value("Java Basics Quiz"))
                .andExpect(jsonPath("$[0].score").value(85))
                .andExpect(jsonPath("$[0].durationMinutes").value(30))
                .andExpect(jsonPath("$[1].attemptId").value(2))
                .andExpect(jsonPath("$[1].examTitle").value("Spring Boot Quiz"))
                .andExpect(jsonPath("$[1].score").value(90));
    }

    /**
     Test xem lịch sử làm bài trả về danh sách rỗng khi chưa có lịch sử
     */
    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetExamHistoryEmpty() throws Exception {
        given(studentService.getExamHistory()).willReturn(List.of());

        mockMvc.perform(get("/api/students/me/exam-history")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }

    /**
     Test xem lịch sử làm bài thất bại khi user không phải STUDENT
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testGetExamHistoryUnauthorized() throws Exception {
        doThrow(new RuntimeException("Chỉ sinh viên mới có thể xem lịch sử làm kiểm tra"))
                .when(studentService).getExamHistory();

        mockMvc.perform(get("/api/students/me/exam-history")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isInternalServerError());
    }
}

