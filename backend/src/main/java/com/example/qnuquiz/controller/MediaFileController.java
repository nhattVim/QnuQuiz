package com.example.qnuquiz.controller;

import com.example.qnuquiz.dto.media.CreateMediaFileRequest;
import com.example.qnuquiz.dto.media.MediaFileDto;
import com.example.qnuquiz.service.MediaFileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/media-files")
@RequiredArgsConstructor
public class MediaFileController {

    private final MediaFileService mediaFileService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public ResponseEntity<MediaFileDto> createMediaFile(@Valid @RequestBody CreateMediaFileRequest request) {
        MediaFileDto mediaFile = mediaFileService.createMediaFile(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(mediaFile);
    }

    @GetMapping("/question/{questionId}")
    public ResponseEntity<List<MediaFileDto>> getMediaFilesByQuestionId(@PathVariable Long questionId) {
        List<MediaFileDto> mediaFiles = mediaFileService.getMediaFilesByQuestionId(questionId);
        return ResponseEntity.ok(mediaFiles);
    }

    @GetMapping("/{id}")
    public ResponseEntity<MediaFileDto> getMediaFileById(@PathVariable Long id) {
        MediaFileDto mediaFile = mediaFileService.getMediaFileById(id);
        return ResponseEntity.ok(mediaFile);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public ResponseEntity<Void> deleteMediaFile(@PathVariable Long id) {
        mediaFileService.deleteMediaFile(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/question/{questionId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public ResponseEntity<Void> deleteMediaFilesByQuestionId(@PathVariable Long questionId) {
        mediaFileService.deleteMediaFilesByQuestionId(questionId);
        return ResponseEntity.noContent().build();
    }
}

