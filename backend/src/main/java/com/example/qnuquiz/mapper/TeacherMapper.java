package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.entity.Teachers;

@Mapper(componentModel = "spring")
public interface TeacherMapper {

    @Mapping(source = "users.username", target = "username")
    @Mapping(source = "users.fullName", target = "fullName")
    @Mapping(source = "users.email", target = "email")
    @Mapping(source = "users.phoneNumber", target = "phoneNumber")
    @Mapping(source = "departments.id", target = "departmentId")
    TeacherDto toDto(Teachers teacher);

    List<TeacherDto> toDtoList(List<Teachers> teachers);
}
