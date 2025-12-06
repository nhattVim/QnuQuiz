package com.example.qnuquiz.service.impl;

import com.example.qnuquiz.service.AppwriteService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
public class AppwriteServiceImpl implements AppwriteService {

    private static final String ENDPOINT = "https://sgp.cloud.appwrite.io/v1";
    private static final String PROJECT_ID = "6933db5d003dd17c7e08";
    private static final String BUCKET_ID = "6933dd860009f1a2e0be";
    
    private static final Pattern FILE_ID_PATTERN = Pattern.compile(
        "/storage/buckets/[^/]+/files/([^/]+)/view"
    );

    private final RestTemplate restTemplate;

    public AppwriteServiceImpl() {
        this.restTemplate = new RestTemplate();
    }

    @Override
    public void deleteFile(String fileUrl) {
        if (fileUrl == null || fileUrl.trim().isEmpty()) {
            log.warn("Cannot delete file: fileUrl is null or empty");
            return;
        }

        try {
            String fileId = extractFileIdFromUrl(fileUrl);
            if (fileId == null) {
                log.warn("Cannot extract fileId from URL: {}", fileUrl);
                return;
            }

            log.info("Deleting file from Appwrite: fileId={}, url={}", fileId, fileUrl);

            String deleteUrl = String.format("%s/storage/buckets/%s/files/%s", 
                ENDPOINT, BUCKET_ID, fileId);

            HttpHeaders headers = new HttpHeaders();
            headers.set("X-Appwrite-Project", PROJECT_ID);
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            ResponseEntity<String> response = restTemplate.exchange(
                deleteUrl,
                HttpMethod.DELETE,
                entity,
                String.class
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                log.info("File deleted successfully from Appwrite: fileId={}", fileId);
            } else {
                log.warn("Failed to delete file from Appwrite: fileId={}, status={}", 
                    fileId, response.getStatusCode());
            }
        } catch (Exception e) {
            log.error("Error deleting file from Appwrite: url={}, error={}", fileUrl, e.getMessage(), e);
        }
    }

    /**
     * Extract fileId from Appwrite file URL
     * 
     * @param fileUrl The full file URL
     * @return The fileId, or null if not found
     */
    private String extractFileIdFromUrl(String fileUrl) {
        if (fileUrl == null) {
            return null;
        }

        Matcher matcher = FILE_ID_PATTERN.matcher(fileUrl);
        if (matcher.find()) {
            return matcher.group(1);
        }

        return null;
    }
}

