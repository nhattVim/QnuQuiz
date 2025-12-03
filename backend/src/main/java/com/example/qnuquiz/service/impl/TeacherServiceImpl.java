package com.example.qnuquiz.service.impl;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.qnuquiz.dto.teacher.TeacherDto;
import com.example.qnuquiz.dto.teacher.TeacherNotificationDto;
import com.example.qnuquiz.entity.Announcements;
import com.example.qnuquiz.entity.Classes;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.Feedbacks;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Teachers;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.TeacherMapper;
import com.example.qnuquiz.repository.AnnouncementRepository;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.FeedbackRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.repository.TeacherRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.TeacherService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class TeacherServiceImpl implements TeacherService {

    private final TeacherMapper teacherMapper;
    private final TeacherRepository teacherRepository;
    private final UserRepository userRepository;
    private final ExamRepository examRepository;
    private final ExamAttemptRepository examAttemptRepository;
    private final AnnouncementRepository announcementRepository;
    private final FeedbackRepository feedbackRepository;
    private final QuestionRepository questionRepository;
    private final StudentRepository studentRepository;

    @Override
    public List<TeacherDto> getAllTeachers() {
        return teacherMapper.toDtoList(teacherRepository.findAll());
    }

    @Override
    @Transactional(readOnly = true)
    public TeacherNotificationDto getNotificationsForCurrentTeacher() {
        UUID currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw new RuntimeException("Không xác định được người dùng hiện tại");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        if (!"TEACHER".equalsIgnoreCase(user.getRole())) {
            throw new RuntimeException("Chỉ giáo viên mới có thể xem thông báo");
        }

        Teachers teacher = teacherRepository.findByUsers(user)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin giáo viên"));

        // Lấy các bài thi mà giáo viên tạo
        List<Exams> teacherExams = examRepository.findByUsers_Id(currentUserId);

        // Lấy các lớp liên quan đến giáo viên (qua các bài thi)
        Set<Long> classIds = new HashSet<>();
        Set<Long> examIds = teacherExams.stream().map(Exams::getId).collect(Collectors.toSet());

        // Lấy các lớp từ exam attempts
        for (Long examId : examIds) {
            List<ExamAttempts> attempts = examAttemptRepository.findByExamsId(examId);
            for (ExamAttempts attempt : attempts) {
                Students student = attempt.getStudents();
                if (student != null && student.getClasses() != null) {
                    classIds.add(student.getClasses().getId());
                }
            }
        }

        // Lấy thông báo
        List<TeacherNotificationDto.ExamAnnouncementDto> examAnnouncements = new ArrayList<>();

        // Thông báo cho tất cả
        List<Announcements> allAnnouncements = announcementRepository.findAllForAll();
        examAnnouncements.addAll(allAnnouncements.stream()
                .map(this::mapToExamAnnouncementDto)
                .collect(Collectors.toList()));

        // Thông báo cho giáo viên
        List<Announcements> teacherAnnouncements = announcementRepository.findAllForTeachers();
        examAnnouncements.addAll(teacherAnnouncements.stream()
                .map(this::mapToExamAnnouncementDto)
                .collect(Collectors.toList()));

        // Thông báo cho các lớp
        if (!classIds.isEmpty()) {
            List<Announcements> classAnnouncements = announcementRepository.findByClassIds(new ArrayList<>(classIds));
            examAnnouncements.addAll(classAnnouncements.stream()
                    .map(this::mapToExamAnnouncementDto)
                    .collect(Collectors.toList()));
        }

        // Thông báo cho khoa của giáo viên
        if (teacher.getDepartments() != null) {
            List<Announcements> deptAnnouncements = announcementRepository
                    .findByDepartmentIdOrAllOrTeacher(teacher.getDepartments().getId());
            examAnnouncements.addAll(deptAnnouncements.stream()
                    .map(this::mapToExamAnnouncementDto)
                    .collect(Collectors.toList()));
        }

        // Loại bỏ trùng lặp (theo ID) và sắp xếp theo thời gian
        examAnnouncements = examAnnouncements.stream()
                .collect(Collectors.toMap(
                    TeacherNotificationDto.ExamAnnouncementDto::getId,
                    dto -> dto,
                    (existing, replacement) -> existing
                ))
                .values()
                .stream()
                .sorted((a, b) -> b.getPublishedAt().compareTo(a.getPublishedAt()))
                .collect(Collectors.toList());

        // Lấy các vấn đề (feedbacks) từ các câu hỏi trong bài thi của giáo viên
        List<TeacherNotificationDto.ClassIssueDto> classIssues = new ArrayList<>();

        // Lấy tất cả câu hỏi trong các bài thi của giáo viên
        Set<Long> questionIds = new HashSet<>();
        for (Long examId : examIds) {
            List<Questions> questions = questionRepository.findByExamsId(examId);
            questionIds.addAll(questions.stream().map(Questions::getId).collect(Collectors.toSet()));
        }

        // Lấy feedbacks cho các câu hỏi đó
        List<Feedbacks> relevantFeedbacks = questionIds.isEmpty() 
                ? new ArrayList<>() 
                : feedbackRepository.findByQuestionIds(new ArrayList<>(questionIds));

        // Map feedbacks thành ClassIssueDto
        for (Feedbacks feedback : relevantFeedbacks) {
            TeacherNotificationDto.ClassIssueDto issueDto = mapToClassIssueDto(feedback);
            classIssues.add(issueDto);
        }

        // Sắp xếp theo thời gian tạo
        classIssues.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));

        return TeacherNotificationDto.builder()
                .examAnnouncements(examAnnouncements)
                .classIssues(classIssues)
                .build();
    }

    private TeacherNotificationDto.ExamAnnouncementDto mapToExamAnnouncementDto(Announcements announcement) {
        return TeacherNotificationDto.ExamAnnouncementDto.builder()
                .id(announcement.getId())
                .title(announcement.getTitle())
                .content(announcement.getContent())
                .target(announcement.getTarget())
                .className(announcement.getClasses() != null ? announcement.getClasses().getName() : null)
                .departmentName(announcement.getDepartments() != null ? announcement.getDepartments().getName() : null)
                .authorName(announcement.getUsers() != null ? announcement.getUsers().getFullName() : null)
                .publishedAt(announcement.getPublishedAt())
                .build();
    }

    private TeacherNotificationDto.ClassIssueDto mapToClassIssueDto(Feedbacks feedback) {
        Questions question = feedback.getQuestions();
        Exams exam = question != null ? question.getExams() : null;
        Users studentUser = feedback.getUsersByUserId();
        Students student = null;
        Classes studentClass = null;

        if (studentUser != null) {
            student = studentRepository.findByUsers(studentUser).orElse(null);
            if (student != null) {
                studentClass = student.getClasses();
            }
        }

        return TeacherNotificationDto.ClassIssueDto.builder()
                .id(feedback.getId())
                .questionContent(question != null ? question.getContent() : null)
                .examId(exam != null ? exam.getId() : null)
                .examTitle(exam != null ? exam.getTitle() : null)
                .studentName(studentUser != null ? studentUser.getFullName() : null)
                .studentCode(student != null ? student.getStudentCode() : null)
                .className(studentClass != null ? studentClass.getName() : null)
                .content(feedback.getContent())
                .status(feedback.getStatus())
                .createdAt(feedback.getCreatedAt())
                .reviewedAt(feedback.getReviewedAt())
                .build();
    }

}
