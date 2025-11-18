package com.example.qnuquiz.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.qnuquiz.dto.department.DepartmentDto;
import com.example.qnuquiz.mapper.DepartmentMapper;
import com.example.qnuquiz.repository.DepartmentRepository;
import com.example.qnuquiz.service.DepartmentService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class DepartmentServiceImpl implements DepartmentService {

    private final DepartmentMapper departmentMapper;
    private final DepartmentRepository departmentRepository;

    @Override
    public List<DepartmentDto> getAllDepartments() {
        return departmentMapper.toDtoList(departmentRepository.findAll());
    }

    @Override
    public DepartmentDto getDepartmentById(Long id) {
        return departmentRepository.findById(id)
                .map(departmentMapper::toDto)
                .orElse(null);
    }
}
