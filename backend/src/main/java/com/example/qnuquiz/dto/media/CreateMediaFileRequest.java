package com.example.qnuquiz.dto.media;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateMediaFileRequest {
    @NotBlank(message = "File URL is required")
    private String fileUrl;
    
    @NotBlank(message = "File name is required")
    private String fileName;
    
    private String mimeType;
    private Long sizeBytes;
    
    @NotNull(message = "Question ID is required")
    private Long questionId;
    
    private String description;
}

