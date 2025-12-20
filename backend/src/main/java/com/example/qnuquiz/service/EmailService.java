package com.example.qnuquiz.service;

public interface EmailService {
    void sendPasswordResetCode(String email, String code);
}
