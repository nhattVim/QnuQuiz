package com.example.qnuquiz.controller;

import com.example.qnuquiz.dto.questions.IdsRequest;
import com.example.qnuquiz.dto.questions.QuestionFullDto;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.QuestionService;

import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class QuestionControllerTest {

    @Mock
    private QuestionService questionService;

    @Mock
    private MultipartFile file;

    @InjectMocks
    private QuestionController questionController;

    private final Long MOCK_EXAM_ID = 1L;

    @BeforeAll
    static void mockSecurityUtils() {
        MockedStatic<SecurityUtils> securityMock = mockStatic(SecurityUtils.class);
        securityMock.when(SecurityUtils::getCurrentUserId)
                .thenReturn(UUID.fromString("00000000-0000-0000-0000-000000000001"));
    }

    @Test
    void importQuestions_Success() throws Exception {
        // WHEN
        ResponseEntity<String> response = questionController.importQuestions(file, MOCK_EXAM_ID);

        // THEN
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Data import successfully!", response.getBody());

        verify(questionService).importQuestionsFromExcel(
                eq(file),
                any(UUID.class),
                eq(MOCK_EXAM_ID));
    }

    @Test
    void importQuestions_Failed() throws Exception {
        // GIVEN
        doThrow(new RuntimeException("Import error"))
                .when(questionService)
                .importQuestionsFromExcel(any(), any(), anyLong());

        // WHEN
        ResponseEntity<String> response = questionController.importQuestions(file, MOCK_EXAM_ID);

        // THEN
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertTrue(response.getBody().contains("Import error"));
    }

    @Test
    void getQuestions_Success() {
        // GIVEN
        List<QuestionFullDto> mockList = List.of(
                QuestionFullDto.builder()
                        .id(1)
                        .content("Q1")
                        .options(List.of())
                        .build());

        when(questionService.getQuestions(MOCK_EXAM_ID)).thenReturn(mockList);

        // WHEN
        ResponseEntity<List<QuestionFullDto>> response = questionController.getQuestions(MOCK_EXAM_ID);

        // THEN
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, response.getBody().size());
        assertEquals("Q1", response.getBody().get(0).getContent());

        verify(questionService).getQuestions(MOCK_EXAM_ID);
    }

    @Test
    void deleteQuestions_Success() {
        // GIVEN
        IdsRequest request = IdsRequest.builder()
                .ids(List.of(10L, 20L))
                .build();

        // WHEN
        ResponseEntity<Map<String, Object>> response = questionController.deleteQuestions(request);

        // THEN
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(true, response.getBody().get("success"));

        verify(questionService).deleteQuestion(List.of(10L, 20L));
    }

    @Test
    void deleteQuestions_EmptyIds() {
        // GIVEN
        IdsRequest request = IdsRequest.builder()
                .ids(List.of())
                .build();

        // WHEN
        ResponseEntity<Map<String, Object>> response = questionController.deleteQuestions(request);

        // THEN
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals(false, response.getBody().get("success"));
        assertEquals("Danh sách ID rỗng", response.getBody().get("message"));

        verify(questionService, never()).deleteQuestion(any());
    }

    @Test
    void deleteQuestions_Failed() {
        // GIVEN
        IdsRequest request = IdsRequest.builder()
                .ids(List.of(1L))
                .build();

        doThrow(new RuntimeException("Delete error"))
                .when(questionService)
                .deleteQuestion(anyList());

        // WHEN
        ResponseEntity<Map<String, Object>> response = questionController.deleteQuestions(request);

        // THEN
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertEquals(false, response.getBody().get("success"));
        assertTrue(response.getBody().get("message").toString().contains("Delete error"));
    }
}
