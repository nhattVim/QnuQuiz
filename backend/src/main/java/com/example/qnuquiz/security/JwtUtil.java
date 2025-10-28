package com.example.qnuquiz.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUtil {

    // Bí mật JWT – nên có độ dài ít nhất 32 ký tự
    private static final String SECRET_KEY = "your-secret-key-should-be-long-and-secure-1234567890";
    private static final long EXPIRATION_MS = 24 * 60 * 60 * 1000; // 1 ngày

    // Tạo secret key đúng kiểu SecretKey
    private final SecretKey key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());

    /** Sinh JWT token */
    public String generateToken(String username) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + EXPIRATION_MS);

        return Jwts.builder()
                .subject(username)
                .issuedAt(now)
                .expiration(expiry)
                .signWith(key) // tự động chọn HS256 tương ứng
                .compact();
    }

    /** Lấy username từ token */
    public String extractUsername(String token) {
        return parseClaims(token).getSubject();
    }

    /** Kiểm tra token hợp lệ */
    public boolean isTokenValid(String token, String username) {
        try {
            String extracted = extractUsername(token);
            return extracted.equals(username) && !isTokenExpired(token);
        } catch (Exception e) {
            return false;
        }
    }

    /** Kiểm tra token hết hạn */
    private boolean isTokenExpired(String token) {
        Date exp = parseClaims(token).getExpiration();
        return exp.before(new Date());
    }

    /** Parse token JWT và trả về phần Claims */
    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(key) // bây giờ kiểu khớp: SecretKey ✅
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
