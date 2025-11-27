package com.example.qnuquiz.controller;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.dto.user.UserLoginDto;
import com.example.qnuquiz.dto.user.UserRegisterDto;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.exception.GlobalExceptionHandler;
import com.example.qnuquiz.security.CustomUserDetailsService;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private AuthenticationManager authManager;

    @MockitoBean
    private UserService userService;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private CustomUserDetailsService customUserDetailsService;

    /**
     * Tests a successful user login scenario.
     * Verifies that the login endpoint returns an OK status, a JWT token, and
     * correct user details.
     */
    @Test
    void testLoginSuccess() throws Exception {
        UUID userId = UUID.randomUUID();
        Users mockUser = new Users();
        mockUser.setId(userId);
        mockUser.setUsername("john");
        mockUser.setEmail("john@example.com");
        mockUser.setRole("STUDENT");

        UserLoginDto loginDto = new UserLoginDto();
        loginDto.setUsername("john");
        loginDto.setPassword("password");

        given(authManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .willReturn(new UsernamePasswordAuthenticationToken(loginDto.getUsername(), loginDto.getPassword()));

        given(userService.findByUsername("john"))
                .willReturn(Optional.of(mockUser));

        given(jwtUtil.generateToken("john"))
                .willReturn("mocked-jwt-token");

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("mocked-jwt-token"))
                .andExpect(jsonPath("$.user.username").value("john"))
                .andExpect(jsonPath("$.user.role").value("STUDENT"))
                .andExpect(jsonPath("$.user.id").value(userId.toString()));
    }

    /**
     * Tests a login attempt with invalid credentials.
     * Verifies that the login endpoint returns an Unauthorized status and an
     * appropriate error message.
     */
    @Test
    void testLogin_AuthFailed_BadCredentials() throws Exception {
        UserLoginDto loginDto = new UserLoginDto();
        loginDto.setUsername("john");
        loginDto.setPassword("wrong_password");

        given(authManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .willThrow(new BadCredentialsException("Bad credentials"));

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginDto)))
                .andExpect(status().isUnauthorized());

        Mockito.verifyNoInteractions(userService);
    }

    /**
     * Tests a login scenario where authentication succeeds but the user is not
     * found in the system.
     * Verifies that an Unauthorized status is returned and a
     * BadCredentialsException is thrown.
     */
    @Test
    void testLogin_AuthSuccess_ButUserNull() throws Exception {
        UserLoginDto loginDto = new UserLoginDto();
        loginDto.setUsername("ghost_user");
        loginDto.setPassword("password");

        given(authManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .willReturn(new UsernamePasswordAuthenticationToken(loginDto.getUsername(), loginDto.getPassword()));

        given(userService.findByUsername("ghost_user"))
                .willReturn(Optional.empty());

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginDto)))
                .andExpect(status().isUnauthorized())
                .andExpect(result -> assertTrue(result.getResolvedException() instanceof BadCredentialsException));
    }

    /**
     * Tests a login attempt that fails due to bad credentials.
     * Verifies that the login endpoint returns an Unauthorized status.
     * This test seems to be a duplicate of `testLogin_AuthFailed_BadCredentials`.
     */
    @Test
    void testLoginFailure_BadCredentials() throws Exception {
        UserLoginDto loginDto = new UserLoginDto();
        loginDto.setUsername("john");
        loginDto.setPassword("wrong_password");

        given(authManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .willThrow(new BadCredentialsException("Bad credentials"));

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginDto)))
                .andExpect(status().isUnauthorized());
    }

    /**
     * Tests a login attempt with invalid input data that fails validation.
     * Verifies that the login endpoint returns a Bad Request status.
     */
    @Test
    void testLoginFailure_Validation() throws Exception {
        UserLoginDto invalidDto = new UserLoginDto();
        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidDto)))
                .andExpect(status().isBadRequest());
    }
}
