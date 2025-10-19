package com.example.qnuquiz.service.impl;

import java.io.IOException;
import java.sql.Timestamp;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.example.qnuquiz.entity.QuestionOptions;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.repository.QuestionOptionsRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.service.QuestionService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class QuestionServiceImpl implements QuestionService {

    private final QuestionRepository questionsRepository;
    private final QuestionOptionsRepository questionOptionsRepository;

    @Override
    public void importQuestionsFromExcel(MultipartFile file) throws IOException {
        try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {
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
                question.setContent(content);
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
}
