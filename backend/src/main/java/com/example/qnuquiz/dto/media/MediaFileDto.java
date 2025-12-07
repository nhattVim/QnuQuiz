package com.example.qnuquiz.dto.media;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MediaFileDto {
    private Long id;
    private String fileName;
    private String fileUrl;
    private String mimeType;
    private Long sizeBytes;
    private Long questionId;
    private String description;
    private Timestamp createdAt;
}

