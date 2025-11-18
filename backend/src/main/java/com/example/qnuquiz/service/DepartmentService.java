package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.department.DepartmentDto;

public interface DepartmentService {

    List<DepartmentDto> getAllDepartments();

    DepartmentDto getDepartmentById(Long id);
}
