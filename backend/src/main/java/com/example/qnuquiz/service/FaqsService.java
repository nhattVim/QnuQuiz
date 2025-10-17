package com.example.qnuquiz.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.entity.Faqs;
import com.example.qnuquiz.repository.FaqsRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FaqsService {

    private final FaqsRepository faqsRepository;

    public List<Faqs> getAllFaqs() {
        return faqsRepository.findAll();
    }
}
