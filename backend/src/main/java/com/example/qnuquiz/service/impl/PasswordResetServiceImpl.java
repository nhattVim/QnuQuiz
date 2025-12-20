package com.example.qnuquiz.service.impl;

import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.example.qnuquiz.service.PasswordResetService;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class PasswordResetServiceImpl implements PasswordResetService {

    // Store reset codes: email -> {code, timestamp}
    private final Map<String, ResetCodeInfo> resetCodes = new ConcurrentHashMap<>();
    private static final int CODE_EXPIRY_MINUTES = 10;
    private static final SecureRandom random = new SecureRandom();

    private static class ResetCodeInfo {
        String code;
        long timestamp;

        ResetCodeInfo(String code) {
            this.code = code;
            this.timestamp = System.currentTimeMillis();
        }

        boolean isExpired() {
            long expiryTime = CODE_EXPIRY_MINUTES * 60 * 1000; // 10 minutes in milliseconds
            return (System.currentTimeMillis() - timestamp) > expiryTime;
        }
    }

    @Override
    public String generateAndStoreResetCode(String email) {
        // Generate 4-digit code
        String code = String.format("%04d", random.nextInt(10000));
        
        // Store code with timestamp
        resetCodes.put(email.toLowerCase(), new ResetCodeInfo(code));
        
        log.info("Generated reset code for email: {}", email);
        return code;
    }

    @Override
    public boolean verifyResetCode(String email, String code) {
        ResetCodeInfo info = resetCodes.get(email.toLowerCase());
        
        if (info == null) {
            log.warn("No reset code found for email: {}", email);
            return false;
        }
        
        if (info.isExpired()) {
            log.warn("Reset code expired for email: {}", email);
            resetCodes.remove(email.toLowerCase());
            return false;
        }
        
        boolean isValid = info.code.equals(code);
        if (!isValid) {
            log.warn("Invalid reset code for email: {}", email);
        }
        
        return isValid;
    }

    @Override
    public void resetPassword(String email, String code) {
        if (!verifyResetCode(email, code)) {
            throw new RuntimeException("Invalid or expired reset code");
        }
        // Code is valid, clear it after password reset
        clearResetCode(email);
    }

    @Override
    public void clearResetCode(String email) {
        resetCodes.remove(email.toLowerCase());
        log.info("Cleared reset code for email: {}", email);
    }

    // Clean up expired codes every 5 minutes
    @Scheduled(fixedRate = 300000) // 5 minutes
    public void cleanupExpiredCodes() {
        resetCodes.entrySet().removeIf(entry -> entry.getValue().isExpired());
    }
}
