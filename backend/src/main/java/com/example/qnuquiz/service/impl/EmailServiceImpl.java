package com.example.qnuquiz.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import com.example.qnuquiz.service.EmailService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EmailServiceImpl implements EmailService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${brevo.from-name:QnuQuiz Team}")
    private String fromName;

    @Value("${brevo.api-key:}")
    private String brevoApiKey;

    @Value("${brevo.from-email:}")
    private String brevoFromEmail;

    @Override
    public void sendPasswordResetCode(String email, String code) {
        if (brevoApiKey == null || brevoApiKey.isEmpty()) {
            throw new IllegalStateException("Brevo API key is not configured. Please set BREVO_API_KEY environment variable.");
        }
        if (brevoFromEmail == null || brevoFromEmail.isEmpty()) {
            throw new IllegalStateException("Brevo sender email is not configured. Please set BREVO_FROM_EMAIL environment variable.");
        }
        sendViaBrevo(email, code);
    }

    private void sendViaBrevo(String toEmail, String code) {
        try {
            String subject = "Mã xác thực đặt lại mật khẩu - QnuQuiz";
            String emailBody = String.format(
            "Xin chào,\n\n" +
            "Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản QnuQuiz của mình.\n\n" +
            "Mã xác thực của bạn là: \n\n" +
            "🔐 %s\n\n" +
            "Mã này có hiệu lực trong 10 phút.\n\n" +
            "Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.\n\n" +
            "Trân trọng,\n" +
            "QnuQuiz Team",
            code
            );

            // Prepare sender
            Map<String, Object> sender = new HashMap<>();
            sender.put("name", fromName);
            sender.put("email", brevoFromEmail);

            // Prepare recipient
            Map<String, Object> recipient = new HashMap<>();
            recipient.put("email", toEmail);

            List<Map<String, Object>> to = new ArrayList<>();
            to.add(recipient);

            // Prepare request body according to Brevo API
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("sender", sender);
            requestBody.put("to", to);
            requestBody.put("subject", subject);
            requestBody.put("textContent", emailBody);

            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("api-key", brevoApiKey);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

            // Send request to Brevo API
            ResponseEntity<String> response = restTemplate.postForEntity(
                "https://api.brevo.com/v3/smtp/email",
                request,
                String.class
            );

            log.info("Brevo email sent successfully. Status: {}, Body: {}", response.getStatusCode(), response.getBody());
        } catch (HttpClientErrorException e) {
            String errorMessage = parseBrevoError(e.getResponseBodyAsString());
            log.error("Brevo API error: {}", errorMessage, e);
            throw new RuntimeException("Failed to send email: " + errorMessage, e);
        } catch (Exception e) {
            log.error("Error sending email via Brevo: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to send email: " + e.getMessage(), e);
        }
    }

    private String parseBrevoError(String responseBody) {
        try {
            if (responseBody != null && !responseBody.isEmpty()) {
                JsonNode jsonNode = objectMapper.readTree(responseBody);
                if (jsonNode.has("message")) {
                    return jsonNode.get("message").asText();
                }
                if (jsonNode.has("code")) {
                    return String.format("Error code: %s", jsonNode.get("code").asText());
                }
            }
        } catch (Exception e) {
            log.debug("Failed to parse Brevo error response: {}", e.getMessage());
        }
        return "Unknown error from Brevo API";
    }
}
