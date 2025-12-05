package com.example.qnuquiz.service.impl;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import com.example.qnuquiz.service.EmailService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String fromEmail;

    @Value("${spring.mail.from-name:QnuQuiz Team}")
    private String fromName;

    @Override
    public void sendPasswordResetCode(String email, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        String fromAddress;
        if (fromEmail != null && !fromEmail.isEmpty()) {
            fromAddress = String.format("%s <%s>", fromName, fromEmail);
        } else {
            fromAddress = fromName;
        }
        message.setFrom(fromAddress);
        message.setTo(email);
        message.setSubject("Mã xác thực đặt lại mật khẩu - QnuQuiz");
        message.setText(String.format(
            "Xin chào,\n\n" +
            "Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản QnuQuiz của mình.\n\n" +
            "Mã xác thực của bạn là: \n\n" +
            "🔐 %s\n\n" +
            "Mã này có hiệu lực trong 10 phút.\n\n" +
            "Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.\n\n" +
            "Trân trọng,\n" +
            "QnuQuiz Team",
            code
        ));
        
        mailSender.send(message);
    }
}
