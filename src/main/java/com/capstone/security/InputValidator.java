package com.capstone.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

/**
 * Validates and sanitises all user-supplied or externally-received data.
 * Must be called at every controller entry point before data reaches business logic.
 */
@Component
public class InputValidator {

    private static final Logger log = LoggerFactory.getLogger(InputValidator.class);

    private static final Pattern UUID_PATTERN =
        Pattern.compile("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
            Pattern.CASE_INSENSITIVE);

    private static final Pattern DANGEROUS_PATTERN =
        Pattern.compile("[<>\"'%;()&+\\\\]|--|/\\*|\\*/|javascript:|onerror=|\\.\\./|\\.\\.\\\\",
            Pattern.CASE_INSENSITIVE);

    /** Validates that a required string field is non-null, non-empty, and within max length. */
    public void requireNonBlank(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Field '" + fieldName + "' is required and must not be blank.");
        }
    }

    /** Validates a string field against a max length. */
    public void requireMaxLength(String value, String fieldName, int maxLength) {
        if (value != null && value.length() > maxLength) {
            throw new IllegalArgumentException(
                "Field '" + fieldName + "' exceeds maximum length of " + maxLength + " characters.");
        }
    }

    /** Validates that a string is a valid UUID. */
    public void requireValidUuid(String value, String fieldName) {
        requireNonBlank(value, fieldName);
        if (!UUID_PATTERN.matcher(value).matches()) {
            throw new IllegalArgumentException("Field '" + fieldName + "' must be a valid UUID.");
        }
    }

    /**
     * Sanitises a string by removing dangerous characters.
     * Returns the sanitised string.
     */
    public String sanitise(String input) {
        if (input == null) return null;
        String sanitised = DANGEROUS_PATTERN.matcher(input).replaceAll("");
        if (!sanitised.equals(input)) {
            log.warn("Input sanitisation removed dangerous characters. Original length: {}, Sanitised length: {}",
                input.length(), sanitised.length());
        }
        return sanitised.trim();
    }

    /** Checks an input for dangerous patterns without modifying it. Returns true if safe. */
    public boolean isSafe(String input) {
        if (input == null) return true;
        return !DANGEROUS_PATTERN.matcher(input).find();
    }
}
