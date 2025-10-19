package com.example.qnuquiz.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.faqs.FaqDto;
import com.example.qnuquiz.mapper.FaqMapper;
import com.example.qnuquiz.repository.FaqRepository;
import com.example.qnuquiz.service.FaqsService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class FaqsServiceImpl implements FaqsService {

    private final FaqMapper faqsMapper;
    private final FaqRepository faqsRepository;

    @Override
    public List<FaqDto> getAllFaqs() {
        return faqsMapper.toDtoList(faqsRepository.findAll());
    }

}
