package com.example.qnuquiz.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.mockito.Mockito.when;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.example.qnuquiz.dto.faqs.FaqDto;
import com.example.qnuquiz.service.FaqsService;

class FaqControllerTest {

    @Mock
    private FaqsService faqService;

    @InjectMocks
    private FaqController faqController;

    public FaqControllerTest() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGetAllFaqs() {
        FaqDto faq = new FaqDto();
        faq.setId(1L);
        faq.setQuestion("What is Spring Boot?");
        faq.setAnswer("Spring Boot simplifies Java development.");
        faq.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        when(faqService.getAllFaqs()).thenReturn(Arrays.asList(faq));

        ResponseEntity<List<FaqDto>> response = faqController.getAllFaqs();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertFalse(response.getBody().isEmpty());
        assertEquals("What is Spring Boot?", response.getBody().get(0).getQuestion());
    }

    @Test
    void testSearchFaq() {
        FaqDto faq = new FaqDto();
        faq.setId(2L);
        faq.setQuestion("How to use JPA?");
        faq.setAnswer("By using Spring Data JPA.");
        faq.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        when(faqService.searchFaq("JPA")).thenReturn(Arrays.asList(faq));

        ResponseEntity<List<FaqDto>> response = faqController.searchFaq("JPA");

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, response.getBody().size());
        assertEquals("How to use JPA?", response.getBody().get(0).getQuestion());
    }

    @Test
    void testUpdateFaq() {
        FaqDto faq = new FaqDto();
        faq.setId(3L);
        faq.setQuestion("Update test?");
        faq.setAnswer("Updated answer.");
        faq.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        when(faqService.updateFaq(faq)).thenReturn(faq);

        ResponseEntity<FaqDto> response = faqController.updateFaq(faq);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Updated answer.", response.getBody().getAnswer());
    }
}
