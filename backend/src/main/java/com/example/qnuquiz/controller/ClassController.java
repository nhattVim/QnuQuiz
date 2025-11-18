package com.example.qnuquiz.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.qnuquiz.dto.classesdto.ClassDto;
import com.example.qnuquiz.service.ClassService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/classes")
public class ClassController {

    private final ClassService classService;

    @GetMapping
    public ResponseEntity<List<ClassDto>> getClasses(
            @RequestParam(required = false) Long departmentId) {
        if (departmentId != null) {
            return ResponseEntity.ok(classService.getClassesByDepartmentId(departmentId));
        }
        return ResponseEntity.ok(classService.getAllClasses());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ClassDto> getClassById(@PathVariable Long id) {
        ClassDto classDto = classService.getClassById(id);
        if (classDto != null) {
            return ResponseEntity.ok(classDto);
        }
        return ResponseEntity.notFound().build();
    }
}
