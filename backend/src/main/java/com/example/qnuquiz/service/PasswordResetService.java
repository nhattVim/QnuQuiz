package com.example.qnuquiz.service;

public interface PasswordResetService {
    String generateAndStoreResetCode(String email);
    boolean verifyResetCode(String email, String code);
    void resetPassword(String email, String code);
    void clearResetCode(String email);
}
