package com.example.qnuquiz.service;

/**
 * Service for interacting with Appwrite Storage
 * Handles file deletion from Appwrite storage
 */
public interface AppwriteService {
    /**
     * Delete file from Appwrite storage
     * 
     * @param fileUrl The full URL of the file to delete
     * @throws RuntimeException if deletion fails
     */
    void deleteFile(String fileUrl);
}

