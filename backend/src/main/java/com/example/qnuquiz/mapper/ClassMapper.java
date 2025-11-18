package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.classesdto.ClassDto;
import com.example.qnuquiz.entity.Classes;

@Mapper(componentModel = "spring")
public interface ClassMapper {

    @Mapping(source = "departments.id", target = "departmentId")
    ClassDto toDto(Classes classes);

    List<ClassDto> toDtoList(List<Classes> classes);

    Classes toEntity(ClassDto classDto);
}
