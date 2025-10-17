package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.entity.Students;

@Mapper(componentModel = "spring")
public interface StudentMapper {

    @Mapping(source = "classes.name", target = "className")
    @Mapping(source = "departments.name", target = "departmentName")
    @Mapping(source = "users.username", target = "userName")
    StudentDto toDto(Students student);

    List<StudentDto> toDtoList(List<Students> students);
}
