package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;

import com.example.qnuquiz.dto.faqs.FaqsDto;
import com.example.qnuquiz.entity.Faqs;

@Mapper(componentModel = "spring")
public interface FaqsMapper {

    FaqsDto toDto(Faqs faqs);

    List<FaqsDto> toDtoList(List<Faqs> faqs);
}
