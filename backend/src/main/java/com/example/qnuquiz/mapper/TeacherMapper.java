package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.entity.Teachers;

@Mapper(componentModel = "spring")
public interface TeacherMapper {

    @Mapping(source = "users.username", target = "userName")
    @Mapping(source = "departments.name", target = "departmentName")
    TeacherDto toDto(Teachers teacher);

    List<TeacherDto> toDtoList(List<Teachers> teachers);
}
