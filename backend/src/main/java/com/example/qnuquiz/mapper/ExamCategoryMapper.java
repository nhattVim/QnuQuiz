package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.exam.ExamCategoryDto;
import com.example.qnuquiz.entity.ExamCategories;

@Mapper(componentModel = "spring")
public interface ExamCategoryMapper {

    @Mapping(target = "totalExams", expression = "java((long)entity.getExamses().size())")
    ExamCategoryDto toDto(ExamCategories entity);

    List<ExamCategoryDto> toDtoList(List<ExamCategories> entities);

    @Mapping(target = "description", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "examses", ignore = true)
    ExamCategories toEntity(ExamCategoryDto dto);
}
