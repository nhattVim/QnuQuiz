package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.example.qnuquiz.dto.announcement.AnnouncementDto;
import com.example.qnuquiz.dto.announcement.CreateAnnouncementDto;
import com.example.qnuquiz.entity.Announcements;
import com.example.qnuquiz.entity.Classes;
import com.example.qnuquiz.entity.Departments;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.AnnouncementRepository;
import com.example.qnuquiz.repository.ClassesRepository;
import com.example.qnuquiz.repository.DepartmentRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.AnnouncementService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class AnnouncementServiceImpl implements AnnouncementService {

    private final AnnouncementRepository announcementRepository;
    private final ClassesRepository classesRepository;
    private final DepartmentRepository departmentRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public AnnouncementDto createAnnouncement(CreateAnnouncementDto dto) {
        // Validate input
        if (dto == null) {
            throw new RuntimeException("Dữ liệu không hợp lệ");
        }

        if (!StringUtils.hasText(dto.getTitle())) {
            throw new RuntimeException("Tiêu đề không được để trống");
        }

        if (!StringUtils.hasText(dto.getContent())) {
            throw new RuntimeException("Nội dung không được để trống");
        }

        if (!StringUtils.hasText(dto.getTarget())) {
            throw new RuntimeException("Vui lòng chọn loại thông báo");
        }

        String target = dto.getTarget().toUpperCase();
        if (!"ALL".equals(target) && !"DEPARTMENT".equals(target) && !"CLASS".equals(target)) {
            throw new RuntimeException("Loại thông báo không hợp lệ. Chỉ chấp nhận: ALL, DEPARTMENT, CLASS");
        }

        // Lấy user hiện tại
        UUID currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw new RuntimeException("Không xác định được người dùng hiện tại");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        // Kiểm tra quyền (chỉ TEACHER hoặc ADMIN mới có thể đăng thông báo)
        if (!"TEACHER".equalsIgnoreCase(user.getRole()) && !"ADMIN".equalsIgnoreCase(user.getRole())) {
            throw new RuntimeException("Chỉ giáo viên hoặc quản trị viên mới có thể đăng thông báo");
        }

        // Validate theo loại thông báo
        Classes targetClass = null;
        Departments targetDepartment = null;

        if ("CLASS".equals(target)) {
            if (dto.getClassId() == null) {
                throw new RuntimeException("Vui lòng chọn lớp");
            }
            targetClass = classesRepository.findById(dto.getClassId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp với ID: " + dto.getClassId()));
            targetDepartment = targetClass.getDepartments();
        } else if ("DEPARTMENT".equals(target)) {
            if (dto.getDepartmentId() == null) {
                throw new RuntimeException("Vui lòng chọn khoa");
            }
            targetDepartment = departmentRepository.findById(dto.getDepartmentId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy khoa với ID: " + dto.getDepartmentId()));
        }
        // ALL không cần classId hoặc departmentId

        // Tạo announcement
        Timestamp now = new Timestamp(System.currentTimeMillis());
        Announcements announcement = new Announcements();
        announcement.setTitle(dto.getTitle());
        announcement.setContent(dto.getContent());
        announcement.setTarget(target);
        announcement.setClasses(targetClass);
        announcement.setDepartments(targetDepartment);
        announcement.setUsers(user);
        announcement.setPublishedAt(now);
        announcement.setCreatedAt(now);

        Announcements saved = announcementRepository.save(announcement);

        // Map to DTO
        return AnnouncementDto.builder()
                .id(saved.getId())
                .title(saved.getTitle())
                .content(saved.getContent())
                .target(saved.getTarget())
                .classId(saved.getClasses() != null ? saved.getClasses().getId() : null)
                .className(saved.getClasses() != null ? saved.getClasses().getName() : null)
                .departmentId(saved.getDepartments() != null ? saved.getDepartments().getId() : null)
                .departmentName(saved.getDepartments() != null ? saved.getDepartments().getName() : null)
                .authorName(saved.getUsers() != null ? saved.getUsers().getFullName() : null)
                .publishedAt(saved.getPublishedAt())
                .createdAt(saved.getCreatedAt())
                .build();
    }

    @Override
    @Transactional
    public void deleteAnnouncement(Long id) {
        // Lấy user hiện tại
        UUID currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw new RuntimeException("Không xác định được người dùng hiện tại");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        // Kiểm tra quyền (chỉ TEACHER hoặc ADMIN mới có thể xóa thông báo)
        if (!"TEACHER".equalsIgnoreCase(user.getRole()) && !"ADMIN".equalsIgnoreCase(user.getRole())) {
            throw new RuntimeException("Chỉ giáo viên hoặc quản trị viên mới có thể xóa thông báo");
        }

        // Kiểm tra thông báo có tồn tại không
        Announcements announcement = announcementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo với ID: " + id));

        // TEACHER và ADMIN đều có thể xóa bất kỳ thông báo nào (ALL, DEPARTMENT, CLASS)
        // Không cần kiểm tra theo ID lớp/khoa vì thông báo ALL không có ID lớp/khoa
        announcementRepository.delete(announcement);
    }

    @Override
    @Transactional
    public void deleteAllAnnouncements() {
        // Lấy user hiện tại
        UUID currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw new RuntimeException("Không xác định được người dùng hiện tại");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        // Kiểm tra quyền (chỉ TEACHER hoặc ADMIN mới có thể xóa thông báo)
        if (!"TEACHER".equalsIgnoreCase(user.getRole()) && !"ADMIN".equalsIgnoreCase(user.getRole())) {
            throw new RuntimeException("Chỉ giáo viên hoặc quản trị viên mới có thể xóa thông báo");
        }

        // TEACHER và ADMIN đều có thể xóa tất cả thông báo
        // Không cần kiểm tra theo ID lớp/khoa vì thông báo ALL không có ID lớp/khoa
        announcementRepository.deleteAll();
    }
}

