package com.example.qnuquiz.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.example.qnuquiz.dto.student.ExamHistoryDto;
import com.example.qnuquiz.dto.student.StudentDto;
import com.example.qnuquiz.dto.user.ChangePasswordRequest;

public interface StudentService {

    List<StudentDto> getAllStudents();

    StudentDto updateCurrentStudentProfile(StudentDto request);

    void changePassword(ChangePasswordRequest request);

    List<ExamHistoryDto> getExamHistory();

    /**
     * Import students from an Excel file (.xlsx).
     * <p>
     * Expected columns (0-based index) on the first sheet:
     * <ul>
     * <li>0: Index (ignored)</li>
     * <li>1: Student Code</li>
     * <li>2: Full Name</li>
     * <li>3: Phone</li>
     * <li>4: Email</li>
     * <li>5: Department name</li>
     * <li>6: Class name</li>
     * <li>7: GPA (optional)</li>
     * </ul>
     */
    void importStudentsFromExcel(MultipartFile file);
}
