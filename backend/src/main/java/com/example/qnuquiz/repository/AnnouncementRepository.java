package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.qnuquiz.entity.Announcements;

import java.util.List;

public interface AnnouncementRepository extends JpaRepository<Announcements, Long> {

    // Lấy thông báo theo lớp
    @Query("SELECT a FROM Announcements a WHERE a.classes.id = :classId ORDER BY a.publishedAt DESC")
    List<Announcements> findByClassId(@Param("classId") Long classId);

    // Lấy thông báo theo khoa
    @Query("SELECT a FROM Announcements a WHERE a.departments.id = :departmentId ORDER BY a.publishedAt DESC")
    List<Announcements> findByDepartmentId(@Param("departmentId") Long departmentId);

    // Lấy thông báo cho tất cả (target = 'ALL')
    @Query("SELECT a FROM Announcements a WHERE a.target = 'ALL' ORDER BY a.publishedAt DESC")
    List<Announcements> findAllForAll();

    // Lấy thông báo cho giáo viên (target = 'TEACHER')
    @Query("SELECT a FROM Announcements a WHERE a.target = 'TEACHER' ORDER BY a.publishedAt DESC")
    List<Announcements> findAllForTeachers();

    // Lấy thông báo theo danh sách lớp
    @Query("SELECT a FROM Announcements a WHERE a.classes.id IN :classIds ORDER BY a.publishedAt DESC")
    List<Announcements> findByClassIds(@Param("classIds") List<Long> classIds);

    // Lấy thông báo theo khoa của giáo viên
    @Query("SELECT a FROM Announcements a WHERE a.departments.id = :departmentId OR a.target = 'ALL' OR a.target = 'TEACHER' ORDER BY a.publishedAt DESC")
    List<Announcements> findByDepartmentIdOrAllOrTeacher(@Param("departmentId") Long departmentId);
}

