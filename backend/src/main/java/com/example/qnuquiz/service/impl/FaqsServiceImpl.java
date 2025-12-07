package com.example.qnuquiz.service.impl;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.faqs.FaqDto;
import com.example.qnuquiz.entity.Faqs;
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

	@Override
	public List<FaqDto> searchFaq(String question) {
	    List<Faqs> faqs = faqsRepository.findByQuestionContainingIgnoreCase(question);

	    if (faqs == null || faqs.isEmpty()) {
	        throw new NoSuchElementException("No FAQ found for keyword: " + question);
	    }
	    return faqs.stream()
	               .map(faqsMapper::toDto)
	               .collect(Collectors.toList());
	}


	@Override
	public FaqDto updateFaq(FaqDto dto) {
		Faqs faqs = faqsRepository.findById(dto.getId())
				.orElseThrow(() -> new RuntimeException("FAQ not found"));
        faqs.setAnswer(dto.getAnswer());
        faqs.setQuestion(dto.getQuestion());
        
        Faqs saved = faqsRepository.save(faqs);
        FaqDto faqDto = faqsMapper.toDto(saved);
       
		return faqDto;
	}
    
    

}
