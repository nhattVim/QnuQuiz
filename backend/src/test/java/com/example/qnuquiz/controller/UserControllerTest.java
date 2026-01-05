package com.example.qnuquiz.controller;

import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;

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

import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.exception.GlobalExceptionHandler;
import com.example.qnuquiz.security.CustomUserDetailsService;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.persistence.EntityNotFoundException;

@WebMvcTest(UserController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class UserControllerTest extends BaseTest {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private CustomUserDetailsService customUserDetailsService;

    @MockitoBean
    private UserService userService;

    @BeforeEach
    void setup() {
        setupSecurityContext("admin", "password", "ROLE_ADMIN");
    }

    /**
     Test cập nhật thông tin cá nhân thành công (ADMIN)
     */
    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateCurrentUserProfileSuccess() throws Exception {
        UUID userId = UUID.randomUUID();
        UserDto userDto = UserDto.builder()
                .id(userId)
                .username("admin")
                .fullName("Admin Updated")
                .email("admin@example.com")
                .phoneNumber("1234567890")
                .role("ADMIN")
                .build();

        UserDto updatedDto = UserDto.builder()
                .id(userId)
                .username("admin")
                .fullName("Admin Updated")
                .email("admin@example.com")
                .phoneNumber("1234567890")
                .role("ADMIN")
                .build();

        given(userService.updateCurrentUserProfile(userDto)).willReturn(updatedDto);

        mockMvc.perform(put("/api/users/me/profile")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(userDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.fullName").value("Admin Updated"))
                .andExpect(jsonPath("$.email").value("admin@example.com"))
                .andExpect(jsonPath("$.phoneNumber").value("1234567890"));
    }

    /**
     Test cập nhật thông tin cá nhân thất bại khi user không tồn tại
     */
    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateCurrentUserProfileNotFound() throws Exception {
        UUID userId = UUID.randomUUID();
        UserDto userDto = UserDto.builder()
                .id(userId)
                .username("admin")
                .fullName("Admin Updated")
                .email("admin@example.com")
                .phoneNumber("1234567890")
                .build();

        doThrow(new RuntimeException("User not found"))
                .when(userService).updateCurrentUserProfile(userDto);

        mockMvc.perform(put("/api/users/me/profile")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(userDto)))
                .andExpect(status().isInternalServerError());
    }

    /**
     Test cập nhật thông tin cá nhân với dữ liệu không hợp lệ
     */
    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateCurrentUserProfileInvalidData() throws Exception {
        UserDto invalidDto = UserDto.builder()
                .username("")
                .email("invalid-email")
                .build();

        mockMvc.perform(put("/api/users/me/profile")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidDto)))
                .andExpect(status().isBadRequest());
    }
}

