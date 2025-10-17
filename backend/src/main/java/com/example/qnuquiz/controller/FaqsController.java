package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.faqs.FaqsDto;
import com.example.qnuquiz.entity.Faqs;
import com.example.qnuquiz.mapper.FaqsMapper;
import com.example.qnuquiz.service.FaqsService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/faqs")
public class FaqsController {

    private final FaqsService faqsService;
    private final FaqsMapper faqsMapper;

    @GetMapping
    public ResponseEntity<List<FaqsDto>> getAllFaqs() {
        List<Faqs> faqs = faqsService.getAllFaqs();
        List<FaqsDto> dtoList = faqsMapper.toDtoList(faqs);
        return ResponseEntity.ok(dtoList);
    }
}
