package com.example.qnuquiz.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.example.qnuquiz.dto.student.ExamAnswerHistoryDto;
import com.example.qnuquiz.dto.student.ExamHistoryDto;
import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.dto.user.ChangePasswordRequest;
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
    private final PasswordEncoder passwordEncoder;

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
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        student.setDepartments(department);
        student.setClasses(classes);

        studentRepository.save(student);
        userRepository.save(user);

        return studentMapper.toDto(student);
    }

    @Override
    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        if (request == null || request.getOldPassword() == null || request.getNewPassword() == null) {
            throw new RuntimeException("Vui lòng điền đầy đủ thông tin mật khẩu");
        }

        if (request.getNewPassword().length() < 6) {
            throw new RuntimeException("Mật khẩu mới phải có ít nhất 6 ký tự");
        }

        UUID currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw new RuntimeException("Không xác định được người dùng hiện tại");
        }

        Users user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        if (!"STUDENT".equalsIgnoreCase(user.getRole())) {
            throw new RuntimeException("Chỉ sinh viên mới có thể đổi mật khẩu");
        }

        // Verify old password
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Mật khẩu hiện tại không đúng");
        }

        // Update password
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
        userRepository.save(user);
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
                .orElseThrow(() -> new RuntimeException("Student not found"));

        // Lấy tất cả các lần làm bài (bao gồm cả chưa hoàn thành)
        List<ExamAttempts> attempts = examAttemptRepository
                .findByStudents_IdOrderByEndTimeDesc(student.getId());

        return attempts.stream().map(attempt -> {
            ExamHistoryDto.ExamHistoryDtoBuilder builder = ExamHistoryDto.builder()
                    .attemptId(attempt.getId())
                    .examId(attempt.getExams().getId())
                    .examTitle(attempt.getExams().getTitle())
                    .examDescription(attempt.getExams().getDescription())
                    .score(attempt.getScore() != null ? attempt.getScore() : 0)
                    .completionDate(attempt.getEndTime())
                    .startTime(attempt.getStartTime())
                    .examDurationMinutes(attempt.getExams().getDurationMinutes());

            if (attempt.getStartTime() != null && attempt.getEndTime() != null) {
                long durationMillis = attempt.getEndTime().getTime() - attempt.getStartTime().getTime();
                long durationMinutes = durationMillis / (1000 * 60);
                builder.durationMinutes(durationMinutes);
            } else {
                builder.durationMinutes(0L);
            }

            List<ExamAnswers> examAnswers = examAnswerRepository.findByExamAttempts_Id(attempt.getId());
            List<ExamAnswerHistoryDto> answerDtos = examAnswers.stream().map(answer -> {
                ExamAnswerHistoryDto.ExamAnswerHistoryDtoBuilder answerBuilder = ExamAnswerHistoryDto.builder()
                        .questionId(answer.getQuestions().getId())
                        .questionContent(answer.getQuestions().getContent())
                        .isCorrect(answer.getIsCorrect())
                        .answerText(answer.getAnswerText());

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
    
    @Override
    @Transactional
    public void importStudentsFromExcel(MultipartFile file) {
        try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {
            Sheet sheet = workbook.getSheetAt(0);
            int rowCount = 0;

            for (Row row : sheet) {
                if (rowCount++ == 0) {
                    // Skip header
                    continue;
                }

                String studentCode = getString(row.getCell(1));
                String fullName = getString(row.getCell(2));
                String phone = getString(row.getCell(3));
                String email = getString(row.getCell(4));
                String departmentName = getString(row.getCell(5));
                String className = getString(row.getCell(6));
                BigDecimal gpa = getGpa(row.getCell(7));

                if (!StringUtils.hasText(studentCode) || !StringUtils.hasText(phone)) {
                    // Required fields missing, skip this row
                    continue;
                }

                String username = studentCode.trim();

                if (userRepository.existsByUsername(username) || studentRepository.existsByStudentCode(studentCode)) {
                    // Skip duplicates
                    continue;
                }

                Departments department = departmentRepository.findByName(departmentName)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy khoa: " + departmentName));

                Classes classes = classesRepository.findByNameAndDepartments_Name(className, departmentName)
                        .orElseThrow(() -> new RuntimeException(
                                "Không tìm thấy lớp: " + className + " thuộc khoa: " + departmentName));

                Timestamp now = new Timestamp(System.currentTimeMillis());

                Users user = new Users();
                user.setUsername(username);
                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhoneNumber(phone);
                user.setStatus("ACTIVE");
                user.setRole("STUDENT");
                user.setPasswordHash(passwordEncoder.encode(phone));
                user.setCreatedAt(now);
                user.setUpdatedAt(now);

                Users savedUser = userRepository.save(user);

                Students student = new Students();
                student.setUsers(savedUser);
                student.setDepartments(department);
                student.setClasses(classes);
                student.setStudentCode(studentCode);
                student.setCreatedAt(now);
                if (gpa != null) {
                    student.setGpa(gpa);
                }

                studentRepository.save(student);
            }
        } catch (Exception e) {
            throw new RuntimeException("Lỗi khi import danh sách sinh viên: " + e.getMessage(), e);
        }
    }

    private String getString(Cell cell) {
        if (cell == null) {
            return "";
        }

        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue().trim();
            case NUMERIC -> String.valueOf(cell.getNumericCellValue());
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            case FORMULA -> cell.getCellFormula();
            case BLANK, _NONE, ERROR -> "";
        };
    }

    private BigDecimal getGpa(Cell cell) {
        if (cell == null) {
            return null;
        }
        try {
            return switch (cell.getCellType()) {
                case STRING -> {
                    String value = cell.getStringCellValue().trim();
                    if (value.isEmpty()) {
                        yield null;
                    }
                    yield new BigDecimal(value).setScale(2, RoundingMode.HALF_UP);
                }
                case NUMERIC -> BigDecimal.valueOf(cell.getNumericCellValue()).setScale(2, RoundingMode.HALF_UP);
                default -> null;
            };
        } catch (Exception e) {
            return null;
        }
    }
}
