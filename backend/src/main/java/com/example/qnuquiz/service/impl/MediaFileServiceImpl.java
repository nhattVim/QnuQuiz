package com.example.qnuquiz.service.impl;

import com.example.qnuquiz.dto.media.CreateMediaFileRequest;
import com.example.qnuquiz.dto.media.MediaFileDto;
import com.example.qnuquiz.entity.MediaFiles;
import com.example.qnuquiz.entity.Questions;
import com.example.qnuquiz.entity.Users;
import com.example.qnuquiz.repository.MediaFileRepository;
import com.example.qnuquiz.repository.QuestionRepository;
import com.example.qnuquiz.repository.UserRepository;
import com.example.qnuquiz.security.SecurityUtils;
import com.example.qnuquiz.service.MediaFileService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MediaFileServiceImpl implements MediaFileService {

    private final MediaFileRepository mediaFileRepository;
    private final QuestionRepository questionRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public MediaFileDto createMediaFile(CreateMediaFileRequest request) {
        var currentUserId = SecurityUtils.getCurrentUserId();
        Users user = null;
        if (currentUserId != null) {
            user = userRepository.findById(currentUserId)
                    .orElse(null);
        }

        if (!questionRepository.existsById(request.getQuestionId())) {
            throw new EntityNotFoundException("Question not found with id: " + request.getQuestionId());
        }

        MediaFiles mediaFile = new MediaFiles();
        mediaFile.setFileName(request.getFileName());
        mediaFile.setFileUrl(request.getFileUrl());
        mediaFile.setMimeType(request.getMimeType());
        mediaFile.setSizeBytes(request.getSizeBytes());
        mediaFile.setUsers(user);
        mediaFile.setRelatedTable("questions");
        mediaFile.setRelatedId(String.valueOf(request.getQuestionId()));
        mediaFile.setDescription(request.getDescription());
        mediaFile.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        MediaFiles saved = mediaFileRepository.save(mediaFile);
        log.info("Media file created: ID={}, Question ID={}", saved.getId(), request.getQuestionId());

        return toDto(saved);
    }

    @Override
    public List<MediaFileDto> getMediaFilesByQuestionId(Long questionId) {
        return mediaFileRepository.findByRelatedTableAndRelatedId("questions", String.valueOf(questionId))
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public MediaFileDto getMediaFileById(Long id) {
        MediaFiles mediaFile = mediaFileRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Media file not found with id: " + id));
        return toDto(mediaFile);
    }

    @Override
    @Transactional
    public void deleteMediaFile(Long id) {
        MediaFiles mediaFile = mediaFileRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Media file not found with id: " + id));
        
        // Backend only handles URL metadata, file deletion is handled by frontend
        mediaFileRepository.deleteById(id);
        log.info("Media file metadata deleted: ID={}", id);
    }

    @Override
    @Transactional
    public void deleteMediaFilesByQuestionId(Long questionId) {
        List<MediaFiles> mediaFiles = mediaFileRepository.findByRelatedTableAndRelatedId(
            "questions", String.valueOf(questionId));
        
        // Backend only handles URL metadata, file deletion is handled by frontend
        mediaFileRepository.deleteByRelatedTableAndRelatedId("questions", String.valueOf(questionId));
        log.info("Media files metadata deleted for question: ID={}, count={}", questionId, mediaFiles.size());
    }

    private MediaFileDto toDto(MediaFiles mediaFile) {
        Long questionId = null;
        if ("questions".equals(mediaFile.getRelatedTable()) && mediaFile.getRelatedId() != null) {
            try {
                questionId = Long.parseLong(mediaFile.getRelatedId());
            } catch (NumberFormatException e) {
            }
        }
        
        return MediaFileDto.builder()
                .id(mediaFile.getId())
                .fileName(mediaFile.getFileName())
                .fileUrl(mediaFile.getFileUrl())
                .mimeType(mediaFile.getMimeType())
                .sizeBytes(mediaFile.getSizeBytes())
                .questionId(questionId)
                .description(mediaFile.getDescription())
                .createdAt(mediaFile.getCreatedAt())
                .build();
    }
}

