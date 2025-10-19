package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;

import com.example.qnuquiz.dto.faqs.FaqDto;
import com.example.qnuquiz.entity.Faqs;

@Mapper(componentModel = "spring")
public interface FaqMapper {

    FaqDto toDto(Faqs faqs);

    List<FaqDto> toDtoList(List<Faqs> faqs);
}
