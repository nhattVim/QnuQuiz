package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.example.qnuquiz.dto.department.DepartmentDto;
import com.example.qnuquiz.entity.Departments;

@Mapper(componentModel = "spring")
public interface DepartmentMapper {

    DepartmentDto toDto(Departments departments);

    List<DepartmentDto> toDtoList(List<Departments> departments);

    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "announcementses", ignore = true)
    @Mapping(target = "classeses", ignore = true)
    @Mapping(target = "studentses", ignore = true)
    @Mapping(target = "teacherses", ignore = true)
    Departments toEntity(DepartmentDto departmentDto);
}
