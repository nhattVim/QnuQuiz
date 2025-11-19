package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;

import com.example.qnuquiz.dto.exam.ExamCategoryDto;
import com.example.qnuquiz.entity.ExamCategories;

@Mapper(componentModel = "spring")
public interface ExamCategoryMapper {

    ExamCategoryDto toDto(ExamCategories entity);

    List<ExamCategoryDto> toDtoList(List<ExamCategories> entities);

    ExamCategories toEntity(ExamCategoryDto dto);
}
