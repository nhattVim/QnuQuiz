package com.example.qnuquiz.service;

import java.util.List;

import com.example.qnuquiz.dto.classesdto.ClassDto;

public interface ClassService {

    List<ClassDto> getAllClasses();

    List<ClassDto> getClassesByDepartmentId(Long departmentId);

    ClassDto getClassById(Long id);
}
