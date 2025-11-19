package com.example.qnuquiz.mapper;

import java.util.List;

import org.mapstruct.Mapper;

import com.example.qnuquiz.dto.department.DepartmentDto;
import com.example.qnuquiz.entity.Departments;

@Mapper(componentModel = "spring")
public interface DepartmentMapper {

    DepartmentDto toDto(Departments departments);

    List<DepartmentDto> toDtoList(List<Departments> departments);

    Departments toEntity(DepartmentDto departmentDto);
}
