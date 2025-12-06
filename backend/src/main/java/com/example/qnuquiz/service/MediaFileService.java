package com.example.qnuquiz.service;

import com.example.qnuquiz.dto.media.CreateMediaFileRequest;
import com.example.qnuquiz.dto.media.MediaFileDto;

import java.util.List;

public interface MediaFileService {
    MediaFileDto createMediaFile(CreateMediaFileRequest request);
    List<MediaFileDto> getMediaFilesByQuestionId(Long questionId);
    MediaFileDto getMediaFileById(Long id);
    void deleteMediaFile(Long id);
    void deleteMediaFilesByQuestionId(Long questionId);
}

