package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Teachers;

public interface TeacherRepository extends JpaRepository<Teachers, Long> {

}
