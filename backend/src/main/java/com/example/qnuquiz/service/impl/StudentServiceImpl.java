package com.example.qnuquiz.service.impl;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.example.qnuquiz.dto.student.ExamAnswerHistoryDto;
import com.example.qnuquiz.dto.student.ExamHistoryDto;
import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.entity.Classes;
import com.example.qnuquiz.entity.Departments;
import com.example.qnuquiz.entity.ExamAnswers;
import com.example.qnuquiz.entity.ExamAttempts;
import com.example.qnuquiz.entity.Students;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.StudentMapper;
import com.example.qnuquiz.repository.ClassesRepository;
import com.example.qnuquiz.repository.DepartmentRepository;
import com.example.qnuquiz.repository.ExamAnswerRepository;
import com.example.qnuquiz.repository.ExamAttemptRepository;
import com.example.qnuquiz.repository.StudentRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.StudentService;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class StudentServiceImpl implements StudentService {

    private final StudentMapper studentMapper;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;
    private final DepartmentRepository departmentRepository;
    private final ClassesRepository classesRepository;
    private final ExamAttemptRepository examAttemptRepository;
    private final ExamAnswerRepository examAnswerRepository;

    @Override
    public List<StudentDto> getAllStudents() {
        return studentMapper.toDtoList(studentRepository.findAll());
    }

    @Override
    @Transactional
    public StudentDto updateCurrentStudentProfile(StudentDto request) {
        if (request == null) {
            throw new RuntimeException("Dữ liệu cập nhật không hợp lệ");
        }

        if (!StringUtils.hasText(request.getFullName()) || !StringUtils.hasText(request.getEmail())
                || !StringUtils.hasText(request.getPhoneNumber())) {
            throw new RuntimeException("Vui lòng điền đầy đủ thông tin họ tên, email và số điện thoại");
        }

        if (request.getDepartmentId() == null || request.getClassId() == null) {
            throw new RuntimeException("Vui lòng chọn khoa và lớp");
        }

        UUID currentUserId = SecurityUtils.getCurrentUserId();

        if (currentUserId == null) {
            throw new RuntimeException("Không xác định được người dùng hiện tại");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        if (!"STUDENT".equalsIgnoreCase(user.getRole())) {
            throw new RuntimeException("Chỉ sinh viên mới có thể cập nhật thông tin cá nhân");
        }

        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin sinh viên"));

        Departments department = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy khoa"));

        Classes classes = classesRepository.findById(request.getClassId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lớp"));

        if (classes.getDepartments() != null && classes.getDepartments().getId() != department.getId()) {
            throw new RuntimeException("Lớp không thuộc khoa đã chọn");
        }

        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        student.setDepartments(department);
        student.setClasses(classes);

        studentRepository.save(student);
        userRepository.save(user);

        return studentMapper.toDto(student);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ExamHistoryDto> getExamHistory() {
        UUID currentUserId = SecurityUtils.getCurrentUserId();

        if (currentUserId == null) {
            throw new RuntimeException("Không xác định được người dùng hiện tại");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        if (!"STUDENT".equalsIgnoreCase(user.getRole())) {
            throw new RuntimeException("Chỉ sinh viên mới có thể xem lịch sử làm kiểm tra");
        }

        Students student = studentRepository.findByUsers(user)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin sinh viên"));

        // Lấy tất cả các bài thi đã nộp của sinh viên
        List<ExamAttempts> attempts = examAttemptRepository
                .findByStudents_IdOrderByEndTimeDesc(student.getId())
                .stream()
                .filter(a -> a.isSubmitted() || a.getEndTime() != null)
                .collect(Collectors.toList());

        return attempts.stream().map(attempt -> {
            ExamHistoryDto.ExamHistoryDtoBuilder builder = ExamHistoryDto.builder()
                    .attemptId(attempt.getId())
                    .examId(attempt.getExams().getId())
                    .examTitle(attempt.getExams().getTitle())
                    .examDescription(attempt.getExams().getDescription())
                    .score(attempt.getScore() != null ? attempt.getScore() : 0)
                    .completionDate(attempt.getEndTime());

            // Tính tổng thời gian làm bài (phút)
            if (attempt.getStartTime() != null && attempt.getEndTime() != null) {
                long durationMillis = attempt.getEndTime().getTime() - attempt.getStartTime().getTime();
                long durationMinutes = durationMillis / (1000 * 60);
                builder.durationMinutes(durationMinutes);
            } else {
                builder.durationMinutes(0L);
            }

            // Lấy danh sách đáp án
            List<ExamAnswers> examAnswers = examAnswerRepository.findByExamAttempts_Id(attempt.getId());
            List<ExamAnswerHistoryDto> answerDtos = examAnswers.stream().map(answer -> {
                ExamAnswerHistoryDto.ExamAnswerHistoryDtoBuilder answerBuilder = ExamAnswerHistoryDto.builder()
                        .questionId(answer.getQuestions().getId())
                        .questionContent(answer.getQuestions().getContent())
                        .isCorrect(answer.getIsCorrect())
                        .answerText(answer.getAnswerText());

                // Nếu có selected option, lấy thông tin option
                if (answer.getQuestionOptions() != null) {
                    answerBuilder.selectedOptionId(answer.getQuestionOptions().getId())
                            .selectedOptionContent(answer.getQuestionOptions().getContent());
                }

                return answerBuilder.build();
            }).collect(Collectors.toList());

            builder.answers(answerDtos);

            return builder.build();
        }).collect(Collectors.toList());
    }

}
