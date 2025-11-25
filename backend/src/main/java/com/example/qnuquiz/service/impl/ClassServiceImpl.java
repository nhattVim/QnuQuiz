package com.example.qnuquiz.service.impl;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.classesdto.ClassDto;
import com.example.qnuquiz.mapper.ClassMapper;
import com.example.qnuquiz.repository.ClassesRepository;
import com.example.qnuquiz.service.ClassService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class ClassServiceImpl implements ClassService {

    private final ClassMapper classMapper;
    private final ClassesRepository classesRepository;

    @Override
    public List<ClassDto> getAllClasses() {
        return classMapper.toDtoList(classesRepository.findAll());
    }

    @Override
    public List<ClassDto> getClassesByDepartmentId(Long departmentId) {
        return classesRepository.findAll().stream()
                .filter(c -> c.getDepartments() != null && c.getDepartments().getId() == departmentId)
                .map(classMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public ClassDto getClassById(Long id) {
        return classesRepository.findById(id)
                .map(classMapper::toDto)
                .orElse(null);
    }
}
