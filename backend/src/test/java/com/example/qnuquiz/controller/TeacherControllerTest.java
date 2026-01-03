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

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.dto.teacher.TeacherNotificationDto;
import com.example.qnuquiz.exception.GlobalExceptionHandler;
import com.example.qnuquiz.security.CustomUserDetailsService;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.TeacherService;
import com.fasterxml.jackson.databind.ObjectMapper;

@WebMvcTest(TeacherController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class TeacherControllerTest extends BaseTest {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private CustomUserDetailsService customUserDetailsService;

    @MockitoBean
    private TeacherService teacherService;

    @BeforeEach
    void setup() {
        setupSecurityContext("teacher", "password", "ROLE_TEACHER");
    }

    /**
      Test cập nhật thông tin cá nhân thành công (TEACHER)
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testUpdateCurrentTeacherProfileSuccess() throws Exception {
        TeacherDto requestDto = TeacherDto.builder()
                .id(1L)
                .username("teacher1")
                .fullName("Teacher Updated")
                .email("teacher@example.com")
                .phoneNumber("0987654321")
                .departmentId(1L)
                .title("Associate Professor")
                .build();

        TeacherDto updatedDto = TeacherDto.builder()
                .id(1L)
                .username("teacher1")
                .fullName("Teacher Updated")
                .email("teacher@example.com")
                .phoneNumber("0987654321")
                .departmentId(1L)
                .title("Associate Professor")
                .build();

        given(teacherService.updateCurrentTeacherProfile(requestDto)).willReturn(updatedDto);

        mockMvc.perform(put("/api/teachers/me/profile")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.fullName").value("Teacher Updated"))
                .andExpect(jsonPath("$.email").value("teacher@example.com"))
                .andExpect(jsonPath("$.phoneNumber").value("0987654321"))
                .andExpect(jsonPath("$.title").value("Associate Professor"));
    }

    /**
     Test cập nhật thông tin cá nhân thất bại khi dữ liệu không hợp lệ
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testUpdateCurrentTeacherProfileInvalidData() throws Exception {
        TeacherDto invalidDto = TeacherDto.builder()
                .fullName("")
                .email("")
                .phoneNumber("")
                .build();

        doThrow(new RuntimeException("Vui lòng điền đầy đủ thông tin họ tên, email và số điện thoại"))
                .when(teacherService).updateCurrentTeacherProfile(invalidDto);

        mockMvc.perform(put("/api/teachers/me/profile")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidDto)))
                .andExpect(status().isInternalServerError());
    }

    /**
     Test giáo viên xem thông báo thành công
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testGetNotificationsSuccess() throws Exception {
        Timestamp publishedAt = Timestamp.from(Instant.now());
        TeacherNotificationDto.ExamAnnouncementDto announcement = TeacherNotificationDto.ExamAnnouncementDto.builder()
                .id(1L)
                .title("Thông báo thi cuối kỳ")
                .content("Lịch thi cuối kỳ sẽ được công bố vào tuần tới")
                .target("ALL")
                .authorName("Admin")
                .publishedAt(publishedAt)
                .build();

        TeacherNotificationDto notificationDto = TeacherNotificationDto.builder()
                .examAnnouncements(List.of(announcement))
                .classIssues(List.of())
                .build();

        given(teacherService.getNotificationsForCurrentTeacher()).willReturn(notificationDto);

        mockMvc.perform(get("/api/teachers/me/notifications")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.examAnnouncements[0].id").value(1))
                .andExpect(jsonPath("$.examAnnouncements[0].title").value("Thông báo thi cuối kỳ"))
                .andExpect(jsonPath("$.examAnnouncements[0].target").value("ALL"))
                .andExpect(jsonPath("$.classIssues").isArray());
    }

    /**
     Test giáo viên xem thông báo trả về danh sách rỗng
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testGetNotificationsEmpty() throws Exception {
        TeacherNotificationDto emptyDto = TeacherNotificationDto.builder()
                .examAnnouncements(List.of())
                .classIssues(List.of())
                .build();

        given(teacherService.getNotificationsForCurrentTeacher()).willReturn(emptyDto);

        mockMvc.perform(get("/api/teachers/me/notifications")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.examAnnouncements").isEmpty())
                .andExpect(jsonPath("$.classIssues").isEmpty());
    }

    /**
     Test giáo viên xem thông báo thất bại khi user không phải TEACHER
     */
    @Test
    @WithMockUser(roles = "STUDENT")
    void testGetNotificationsUnauthorized() throws Exception {
        doThrow(new RuntimeException("Chỉ giáo viên mới có thể xem thông báo"))
                .when(teacherService).getNotificationsForCurrentTeacher();

        mockMvc.perform(get("/api/teachers/me/notifications")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isInternalServerError());
    }
}

