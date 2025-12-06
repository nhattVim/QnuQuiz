package com.example.qnuquiz.service.impl;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.example.qnuquiz.dto.media.MediaFileDto;
import com.example.qnuquiz.dto.questions.QuestionDTO;
import com.example.qnuquiz.dto.questions.QuestionOptionDto;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.mapper.QuestionMapper;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.QuestionOptionsRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.MediaFileService;
import com.example.qnuquiz.service.QuestionService;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class QuestionServiceImpl implements QuestionService {

    private final QuestionRepository questionsRepository;
    private final QuestionOptionsRepository questionOptionsRepository;
    private final UserRepository userRepository;
    private final ExamRepository examRepository;
    private final QuestionMapper questionMapper;
    private final MediaFileService mediaFileService;

    @Override
    @CacheEvict(value = "allQuestionsOfExam", allEntries = true)
    public void importQuestionsFromExcel(MultipartFile file, UUID userId, Long examId) throws IOException {
        try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {

            Users user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            Exams exam = examRepository.findById(examId)
                    .orElseThrow(() -> new RuntimeException("Exam not found"));

            if (!exam.getUsers().getId().equals(userId)) {
                throw new RuntimeException("You are not allowed to add questions to this exam");
            }

            Sheet sheet = workbook.getSheetAt(0);
            int rowCount = 0;

            for (Row row : sheet) {
                if (rowCount++ == 0)
                    continue;

                String content = getString(row.getCell(0));
                String opt1 = getString(row.getCell(1));
                String opt2 = getString(row.getCell(2));
                String opt3 = getString(row.getCell(3));
                String opt4 = getString(row.getCell(4));
                int correct = (int) row.getCell(5).getNumericCellValue();

                Questions question = new Questions();
                question.setExams(exam);
                question.setUsers(user);
                question.setContent(content);
                question.setOrdering(rowCount - 1);
                question.setType("MULTIPLE_CHOICE");
                question.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                question.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
                question = questionsRepository.save(question);

                createOption(question, opt1, correct == 1, 1);
                createOption(question, opt2, correct == 2, 2);
                createOption(question, opt3, correct == 3, 3);
                createOption(question, opt4, correct == 4, 4);
            }
        }
    }

    private void createOption(Questions question, String content, boolean isCorrect, int position) {
        QuestionOptions opt = new QuestionOptions();
        opt.setQuestions(question);
        opt.setContent(content);
        opt.setIsCorrect(isCorrect);
        opt.setPosition(position);
        opt.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        questionOptionsRepository.save(opt);
    }

    private String getString(Cell cell) {
        if (cell == null)
            return "";

        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue().trim();
            case NUMERIC -> String.valueOf(cell.getNumericCellValue());
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            case FORMULA -> cell.getCellFormula();
            case BLANK, _NONE, ERROR -> "";
        };
    }

    @Override
    @Cacheable("allQuestionsOfExam")
    public List<QuestionDTO> getAllQuestionsInExam(Long examId) {
        if (!examRepository.existsById(examId)) {
            throw new RuntimeException("Exam not found");
        }

        return questionsRepository.findByExamsId(examId).stream()
                .map(this::buildQuestionDTO)
                .toList();
    }

    @Override
    @Transactional
    @CacheEvict(value = "allQuestionsOfExam", allEntries = true)
    public void deleteQuestion(List<Long> ids) {
        questionOptionsRepository.deleteAllByQuestions_IdIn(ids);
        questionsRepository.deleteAllById(ids);
    }

    @Override
    @Transactional
    @CacheEvict(value = "allQuestionsOfExam", allEntries = true)
    public QuestionDTO updateQuestion(QuestionDTO dto) {
        Questions question = questionsRepository.findById(dto.getId())
                .orElseThrow(() -> new RuntimeException("Question not found"));

        question.setContent(dto.getContent());

        List<QuestionOptionDto> updatedOptions;
        if (dto.getOptions() != null && !dto.getOptions().isEmpty()) {
            // Update options if provided
            updatedOptions = dto.getOptions().stream()
                .map(optionDto -> {
                    QuestionOptions option = questionOptionsRepository.findById(optionDto.getId())
                            .orElseThrow(() -> new RuntimeException("Option not found with id: " + optionDto.getId()));
                    option.setContent(optionDto.getContent());
                    option.setIsCorrect(optionDto.isCorrect());
                    option.setPosition(optionDto.getPosition());
                    questionOptionsRepository.save(option);
                    return QuestionOptionDto.builder()
                            .id(option.getId())
                            .content(option.getContent())
                            .correct(option.isIsCorrect())
                            .position(option.getPosition())
                            .build();
                })
                .collect(Collectors.toList());
        } else {
            // If options is null or empty, fetch existing options from database
            updatedOptions = questionOptionsRepository.findByQuestions_Id(question.getId())
                    .stream()
                    .map(opt -> QuestionOptionDto.builder()
                            .id(opt.getId())
                            .content(opt.getContent())
                            .correct(opt.isIsCorrect())
                            .position(opt.getPosition())
                            .build())
                    .collect(Collectors.toList());
        }

        questionsRepository.save(question);

        return QuestionDTO.builder()
                .id(question.getId())
                .content(question.getContent())
                .type(question.getType())
                .options(updatedOptions)
                .build();
    }

    private Users getCurrentAuthenticatedUser() {
        UUID userId = SecurityUtils.getCurrentUserId();
        userId = userId == null ? null : userId;
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public List<QuestionDTO> getAllQuestions() {
        return questionsRepository.findAll().stream()
                .map(this::buildQuestionDTO)
                .toList();
    }

    @Override
    @Transactional
    @CacheEvict(value = "allQuestionsOfExam", allEntries = true)
    public QuestionDTO createQuestion(QuestionDTO dto, Long examId) {
        Exams exam = examRepository.findById(examId)
                .orElseThrow(() -> new RuntimeException("Exam not found with id: " + examId));

        Users user = getCurrentAuthenticatedUser();

        if (!exam.getUsers().getId().equals(user.getId())) {
            throw new RuntimeException("You are not allowed to add questions to this exam");
        }

        Questions question = questionMapper.toEntity(dto);
        question.setExams(exam);
        question.setUsers(user);

        List<Questions> allQuestions = questionsRepository.findByExamsId(exam.getId());
        question.setOrdering(allQuestions.size() + 1);
        question.setType(dto.getType());

        question.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        question.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        Questions savedQuestion = questionsRepository.save(question);

        // Validate and create options based on question type
        if (dto.getOptions() != null && !dto.getOptions().isEmpty()) {
            // MULTIPLE_CHOICE questions require options
            if ("MULTIPLE_CHOICE".equalsIgnoreCase(dto.getType()) || "TRUE_FALSE".equalsIgnoreCase(dto.getType())) {
        dto.getOptions().forEach(optionDto -> createOption(savedQuestion, optionDto.getContent(), optionDto.isCorrect(),
                optionDto.getPosition()));
            }
        } else if ("MULTIPLE_CHOICE".equalsIgnoreCase(dto.getType()) || "TRUE_FALSE".equalsIgnoreCase(dto.getType())) {
            // MULTIPLE_CHOICE and TRUE_FALSE questions must have options
            throw new RuntimeException("Options are required for MULTIPLE_CHOICE and TRUE_FALSE question types");
        }

        List<QuestionOptionDto> createdOptions = questionOptionsRepository.findByQuestions_Id(savedQuestion.getId())
                .stream()
                .map(opt -> QuestionOptionDto.builder()
                        .id(opt.getId())
                        .content(opt.getContent())
                        .correct(opt.isIsCorrect())
                        .position(opt.getPosition())
                        .build())
                .collect(Collectors.toList());

        return buildQuestionDTO(savedQuestion);
    }

    /**
     * Helper method to build QuestionDTO with options and media files
     */
    private QuestionDTO buildQuestionDTO(Questions question) {
        // Load options
        List<QuestionOptionDto> options = questionOptionsRepository.findByQuestions_Id(question.getId()).stream()
                .map(o -> QuestionOptionDto.builder()
                        .id(o.getId())
                        .content(o.getContent())
                        .correct(o.isIsCorrect())
                        .position(o.getPosition())
                        .build())
                .toList();

        // Load media files
        List<MediaFileDto> mediaFiles = mediaFileService.getMediaFilesByQuestionId(question.getId());

        // Build DTO
        QuestionDTO.QuestionDTOBuilder builder = QuestionDTO.builder()
                .id(question.getId())
                .content(question.getContent())
                .type(question.getType())
                .options(options)
                .mediaFiles(mediaFiles);

        // For backward compatibility, set mediaUrl to first media file URL if exists
        if (!mediaFiles.isEmpty()) {
            builder.mediaUrl(mediaFiles.get(0).getFileUrl());
        }

        return builder.build();
    }
}
