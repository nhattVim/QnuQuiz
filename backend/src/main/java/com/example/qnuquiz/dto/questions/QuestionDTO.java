package com.example.qnuquiz.dto.questions;

import java.util.List;

import com.example.qnuquiz.dto.media.MediaFileDto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

//DTO cho Question
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuestionDTO {
    private long id;
    private String content;
    private String type; // "ESSAY" hoặc "MULTIPLE_CHOICE"
    private String mediaUrl; // Deprecated: Use mediaFiles instead
    private List<MediaFileDto> mediaFiles; // List of media files (images, videos, audio)
    private List<QuestionOptionDto> options;
}
