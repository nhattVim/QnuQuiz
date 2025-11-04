package com.example.qnuquiz.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public class SecurityUtils {

    public static CustomUserDetails getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !(authentication.getPrincipal() instanceof CustomUserDetails)) {
            return null;
        }

        return (CustomUserDetails) authentication.getPrincipal();
    }

    public static String getCurrentUsername() {
        CustomUserDetails user = getCurrentUser();
        return user != null ? user.getUsername() : null;
    }

    public static java.util.UUID getCurrentUserId() {
        CustomUserDetails user = getCurrentUser();
        return user != null ? user.getId() : null;
    }
}
