package com.example.qnuquiz.controller;

import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.sql.Timestamp;
import java.time.Instant;

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

import com.example.qnuquiz.dto.announcement.AnnouncementDto;
import com.example.qnuquiz.dto.announcement.CreateAnnouncementDto;
import com.example.qnuquiz.exception.GlobalExceptionHandler;
import com.example.qnuquiz.security.CustomUserDetailsService;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.AnnouncementService;
import com.fasterxml.jackson.databind.ObjectMapper;

@WebMvcTest(AnnouncementController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class AnnouncementControllerTest extends BaseTest {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private CustomUserDetailsService customUserDetailsService;

    @MockitoBean
    private AnnouncementService announcementService;

    @BeforeEach
    void setup() {
        setupSecurityContext("teacher", "password", "ROLE_TEACHER");
    }

    /**
     Test giáo viên đăng thông báo thành công (target = ALL)
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testCreateAnnouncementSuccess_ALL() throws Exception {
        Timestamp publishedAt = Timestamp.from(Instant.now());
        CreateAnnouncementDto createDto = CreateAnnouncementDto.builder()
                .title("Thông báo thi cuối kỳ")
                .content("Lịch thi cuối kỳ sẽ được công bố vào tuần tới")
                .target("ALL")
                .build();

        AnnouncementDto announcementDto = AnnouncementDto.builder()
                .id(1L)
                .title("Thông báo thi cuối kỳ")
                .content("Lịch thi cuối kỳ sẽ được công bố vào tuần tới")
                .target("ALL")
                .authorName("Teacher Name")
                .publishedAt(publishedAt)
                .createdAt(publishedAt)
                .build();

        given(announcementService.createAnnouncement(createDto)).willReturn(announcementDto);

        mockMvc.perform(post("/api/announcements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.title").value("Thông báo thi cuối kỳ"))
                .andExpect(jsonPath("$.content").value("Lịch thi cuối kỳ sẽ được công bố vào tuần tới"))
                .andExpect(jsonPath("$.target").value("ALL"));
    }

    /**
    Test giáo viên đăng thông báo thành công (target = DEPARTMENT)
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testCreateAnnouncementSuccess_DEPARTMENT() throws Exception {
        Timestamp publishedAt = Timestamp.from(Instant.now());
        CreateAnnouncementDto createDto = CreateAnnouncementDto.builder()
                .title("Thông báo khoa CNTT")
                .content("Thông báo dành cho khoa CNTT")
                .target("DEPARTMENT")
                .departmentId(1L)
                .build();

        AnnouncementDto announcementDto = AnnouncementDto.builder()
                .id(2L)
                .title("Thông báo khoa CNTT")
                .content("Thông báo dành cho khoa CNTT")
                .target("DEPARTMENT")
                .departmentId(1L)
                .departmentName("Khoa CNTT")
                .authorName("Teacher Name")
                .publishedAt(publishedAt)
                .createdAt(publishedAt)
                .build();

        given(announcementService.createAnnouncement(createDto)).willReturn(announcementDto);

        mockMvc.perform(post("/api/announcements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.target").value("DEPARTMENT"))
                .andExpect(jsonPath("$.departmentId").value(1));
    }

    /**
     Test giáo viên đăng thông báo thành công (target = CLASS)
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testCreateAnnouncementSuccess_CLASS() throws Exception {
        Timestamp publishedAt = Timestamp.from(Instant.now());
        CreateAnnouncementDto createDto = CreateAnnouncementDto.builder()
                .title("Thông báo lớp K61")
                .content("Thông báo dành cho lớp K61")
                .target("CLASS")
                .classId(1L)
                .build();

        AnnouncementDto announcementDto = AnnouncementDto.builder()
                .id(3L)
                .title("Thông báo lớp K61")
                .content("Thông báo dành cho lớp K61")
                .target("CLASS")
                .classId(1L)
                .className("K61")
                .authorName("Teacher Name")
                .publishedAt(publishedAt)
                .createdAt(publishedAt)
                .build();

        given(announcementService.createAnnouncement(createDto)).willReturn(announcementDto);

        mockMvc.perform(post("/api/announcements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.target").value("CLASS"))
                .andExpect(jsonPath("$.classId").value(1));
    }

    /**
     Test đăng thông báo thất bại khi thiếu tiêu đề
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testCreateAnnouncementMissingTitle() throws Exception {
        CreateAnnouncementDto createDto = CreateAnnouncementDto.builder()
                .title("")
                .content("Nội dung thông báo")
                .target("ALL")
                .build();

        doThrow(new RuntimeException("Tiêu đề không được để trống"))
                .when(announcementService).createAnnouncement(createDto);

        mockMvc.perform(post("/api/announcements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createDto)))
                .andExpect(status().isInternalServerError());
    }

    /**
    Test đăng thông báo thất bại khi thiếu nội dung
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testCreateAnnouncementMissingContent() throws Exception {
        CreateAnnouncementDto createDto = CreateAnnouncementDto.builder()
                .title("Tiêu đề")
                .content("")
                .target("ALL")
                .build();

        doThrow(new RuntimeException("Nội dung không được để trống"))
                .when(announcementService).createAnnouncement(createDto);

        mockMvc.perform(post("/api/announcements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createDto)))
                .andExpect(status().isInternalServerError());
    }

    /**
     Test đăng thông báo thất bại khi target = CLASS nhưng thiếu classId
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testCreateAnnouncementCLASSWithoutClassId() throws Exception {
        CreateAnnouncementDto createDto = CreateAnnouncementDto.builder()
                .title("Thông báo lớp")
                .content("Nội dung")
                .target("CLASS")
                .classId(null)
                .build();

        doThrow(new RuntimeException("Vui lòng chọn lớp"))
                .when(announcementService).createAnnouncement(createDto);

        mockMvc.perform(post("/api/announcements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createDto)))
                .andExpect(status().isInternalServerError());
    }

    /**
     Test đăng thông báo thất bại khi target = DEPARTMENT nhưng thiếu departmentId
     */
    @Test
    @WithMockUser(roles = "TEACHER")
    void testCreateAnnouncementDEPARTMENTWithoutDepartmentId() throws Exception {
        CreateAnnouncementDto createDto = CreateAnnouncementDto.builder()
                .title("Thông báo khoa")
                .content("Nội dung")
                .target("DEPARTMENT")
                .departmentId(null)
                .build();

        doThrow(new RuntimeException("Vui lòng chọn khoa"))
                .when(announcementService).createAnnouncement(createDto);

        mockMvc.perform(post("/api/announcements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createDto)))
                .andExpect(status().isInternalServerError());
    }

    /**
     Test đăng thông báo thất bại khi user không phải TEACHER
     */
    @Test
    @WithMockUser(roles = "STUDENT")
    void testCreateAnnouncementUnauthorized() throws Exception {
        CreateAnnouncementDto createDto = CreateAnnouncementDto.builder()
                .title("Thông báo")
                .content("Nội dung")
                .target("ALL")
                .build();

        mockMvc.perform(post("/api/announcements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createDto)))
                .andExpect(status().isForbidden());
    }
}

