package com.example.qnuquiz.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;

import com.example.qnuquiz.dto.user.UserDto;
import com.example.qnuquiz.dto.user.UserLoginDto;
import com.example.qnuquiz.dto.user.UserRegisterDto;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.security.JwtUtil;
import com.example.qnuquiz.service.UserService;

@ExtendWith(MockitoExtension.class)
public class AuthControllerTest {

    @Mock
    private AuthenticationManager authManager;

    @Mock
    private UserService userService;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private AuthController authController;

    private UserLoginDto loginRequest;
    private Users mockUser;
    private final String MOCK_USERNAME = "testuser";
    private final String MOCK_PASSWORD = "password123";
    private final UUID MOCK_ID = UUID.randomUUID();
    private final String MOCK_ROLE = "USER";
    private final String MOCK_EMAIL = "user@example.com";
    private final String MOCK_JWT = "mocked.jwt.token";

    @BeforeEach
    void setUp() {
        loginRequest = new UserLoginDto(MOCK_USERNAME, MOCK_PASSWORD);
        mockUser = new Users();
        mockUser.setId(MOCK_ID);
        mockUser.setUsername(MOCK_USERNAME);
        mockUser.setEmail(MOCK_EMAIL);
        mockUser.setRole(MOCK_ROLE);
    }

    @Test
    void login_Success() {
        // GIVEN:
        when(userService.findByUsername(MOCK_USERNAME)).thenReturn(Optional.of(mockUser));
        when(jwtUtil.generateToken(MOCK_USERNAME)).thenReturn(MOCK_JWT);

        // WHEN:
        Map<String, Object> response = authController.login(loginRequest);

        // THEN:
        assertNotNull(response);
        assertEquals(MOCK_JWT, response.get("token"));

        @SuppressWarnings("unchecked")
        Map<String, Object> userDetails = (Map<String, Object>) response.get("user");

        assertNotNull(userDetails);
        assertEquals(MOCK_ID, userDetails.get("id"));
        assertEquals(MOCK_USERNAME, userDetails.get("username"));
        assertEquals(MOCK_EMAIL, userDetails.get("email"));
        assertEquals(MOCK_ROLE, userDetails.get("role"));

        verify(authManager).authenticate(new UsernamePasswordAuthenticationToken(MOCK_USERNAME, MOCK_PASSWORD));
        verify(userService).findByUsername(MOCK_USERNAME);
        verify(jwtUtil).generateToken(MOCK_USERNAME);
    }

    @Test
    void login_AuthenticationFails() {
        // GIVEN
        doThrow(new RuntimeException("Bad credentials")).when(authManager).authenticate(any(Authentication.class));

        // WHEN & THEN
        assertThrows(RuntimeException.class, () -> {
            authController.login(loginRequest);
        });

        verify(userService, never()).findByUsername(anyString());
        verify(jwtUtil, never()).generateToken(anyString());
    }

    @Test
    void login_UserNotFoundAfterAuthentication() {
        // GIVEN:
        when(userService.findByUsername(MOCK_USERNAME)).thenReturn(Optional.empty());

        // WHEN & THEN:
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authController.login(loginRequest);
        });

        assertEquals("User not found", exception.getMessage());

        verify(authManager).authenticate(any(Authentication.class));
        verify(userService).findByUsername(MOCK_USERNAME);
        verify(jwtUtil, never()).generateToken(anyString());
    }

    @Test
    void register_Success() {
        // GIVEN:
        UserRegisterDto registerDto = new UserRegisterDto("newuser", "newpass", "new@example.com", MOCK_EMAIL,
                MOCK_EMAIL, MOCK_EMAIL);
        UserDto registeredUserDto = new UserDto(UUID.randomUUID(), "newuser", "new@example.com", "USER", MOCK_EMAIL,
                MOCK_EMAIL, MOCK_EMAIL, null, null);

        when(userService.register(registerDto)).thenReturn(registeredUserDto);

        // WHEN:
        ResponseEntity<UserDto> response = authController.register(registerDto);

        // THEN:
        assertNotNull(response);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(registeredUserDto, response.getBody());

        verify(userService).register(registerDto);
    }

    @Test
    void register_UserServiceThrowsException() {
        // GIVEN:
        UserRegisterDto registerDto = new UserRegisterDto("existinguser", "pass", "exist@example.com", MOCK_EMAIL,
                MOCK_EMAIL, MOCK_EMAIL);
        String errorMessage = "Username already exists";
        when(userService.register(registerDto)).thenThrow(new IllegalStateException(errorMessage));

        // WHEN & THEN:
        IllegalStateException exception = assertThrows(IllegalStateException.class, () -> {
            authController.register(registerDto);
        });

        assertEquals(errorMessage, exception.getMessage());

        verify(userService).register(registerDto);
    }
}
