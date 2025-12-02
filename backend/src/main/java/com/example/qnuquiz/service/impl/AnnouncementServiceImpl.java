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
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.AnnouncementRepository;
import com.example.qnuquiz.repository.ClassesRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.AnnouncementService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class AnnouncementServiceImpl implements AnnouncementService {

    private final AnnouncementRepository announcementRepository;
    private final ClassesRepository classesRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public AnnouncementDto createAnnouncementForClass(CreateAnnouncementDto dto) {
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

        if (dto.getClassId() == null) {
            throw new RuntimeException("Vui lòng chọn lớp");
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

        // Kiểm tra lớp có tồn tại không
        Classes targetClass = classesRepository.findById(dto.getClassId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp với ID: " + dto.getClassId()));

        // Tạo announcement
        Timestamp now = new Timestamp(System.currentTimeMillis());
        Announcements announcement = new Announcements();
        announcement.setTitle(dto.getTitle());
        announcement.setContent(dto.getContent());
        announcement.setTarget("CLASS");
        announcement.setClasses(targetClass);
        announcement.setUsers(user);
        announcement.setDepartments(targetClass.getDepartments());
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

        // Kiểm tra quyền: chỉ người tạo hoặc ADMIN mới có thể xóa
        if (!"ADMIN".equalsIgnoreCase(user.getRole()) 
                && (announcement.getUsers() == null || !announcement.getUsers().getId().equals(currentUserId))) {
            throw new RuntimeException("Bạn không có quyền xóa thông báo này");
        }

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

        // Lấy tất cả thông báo của người dùng hiện tại (hoặc tất cả nếu là ADMIN)
        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            announcementRepository.deleteAll();
        } else {
            // Xóa tất cả thông báo do giáo viên này tạo
            announcementRepository.findAll().stream()
                    .filter(a -> a.getUsers() != null && a.getUsers().getId().equals(currentUserId))
                    .forEach(announcementRepository::delete);
        }
    }
}

