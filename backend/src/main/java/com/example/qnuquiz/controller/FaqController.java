package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.faqs.FaqDto;
import com.example.qnuquiz.service.FaqsService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/faqs")
public class FaqController {

    private final FaqsService faqService;

    @GetMapping
    public ResponseEntity<List<FaqDto>> getAllFaqs() {
        return ResponseEntity.ok(faqService.getAllFaqs());
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<FaqDto>> searchFaq(@RequestParam String question) {
        return ResponseEntity.ok(faqService.searchFaq(question));
    }
    
    @PostMapping("/update")
    public ResponseEntity<FaqDto> updateFaq(@RequestBody FaqDto dto){
    	return ResponseEntity.ok(faqService.updateFaq(dto));
    }

}
