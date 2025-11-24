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

import com.example.qnuquiz.dto.questions.QuestionFullDto;
import com.example.qnuquiz.dto.questions.QuestionOptionDto;
import com.example.qnuquiz.entity.Exams;
import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.ExamRepository;
import com.example.qnuquiz.repository.QuestionOptionsRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.UserRepository;
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
        opt.setCorrect(isCorrect);
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
    public List<QuestionFullDto> getQuestions(Long examId) {
        if (!examRepository.existsById(examId)) {
            throw new RuntimeException("Exam not found");
        }

        return questionsRepository.findByExamsId(examId).stream()
                .map(q -> QuestionFullDto.builder()
                        .id(q.getId())
                        .content(q.getContent())
                        .point(q.getPoints())
                        .options(questionOptionsRepository.findByQuestions_Id(q.getId()).stream()
                                .map(o -> QuestionOptionDto.builder()
                                        .id(o.getId())
                                        .content(o.getContent())
                                        .correct(o.getCorrect())
                                        .build())
                                .toList())
                        .build())
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
    public QuestionFullDto updateQuestion(QuestionFullDto dto) {
        Questions question = questionsRepository.findById(dto.getId())
                .orElseThrow(() -> new RuntimeException("Question not found"));

        question.setContent(dto.getContent());

        List<QuestionOptionDto> updatedOptions = dto.getOptions().stream()
                .map(optionDto -> {
                    QuestionOptions option = questionOptionsRepository.findById(optionDto.getId())
                            .orElseThrow(() -> new RuntimeException("Option not found with id: " + optionDto.getId()));
                    option.setContent(optionDto.getContent());
                    option.setCorrect(optionDto.isCorrect());
                    questionOptionsRepository.save(option);
                    return QuestionOptionDto.builder()
                            .id(option.getId())
                            .content(option.getContent())
                            .correct(option.getCorrect())
                            .build();
                })
                .collect(Collectors.toList());

        questionsRepository.save(question);

        return QuestionFullDto.builder()
                .id(question.getId())
                .content(question.getContent())
                .options(updatedOptions)
                .build();
    }
}
