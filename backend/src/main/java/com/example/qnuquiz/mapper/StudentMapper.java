package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.entity.Students;

@Mapper(componentModel = "spring")
public interface StudentMapper {

    @Mapping(source = "classes.id", target = "classId")
    @Mapping(source = "departments.id", target = "departmentId")
    @Mapping(source = "users.username", target = "username")
    @Mapping(source = "users.fullName", target = "fullName")
    @Mapping(source = "users.email", target = "email")
    @Mapping(source = "users.phoneNumber", target = "phoneNumber")
    @Mapping(source = "users.avatarUrl", target = "avatarUrl")
    StudentDto toDto(Students student);

    List<StudentDto> toDtoList(List<Students> students);
}
