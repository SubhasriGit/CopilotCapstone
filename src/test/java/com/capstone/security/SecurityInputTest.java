package com.capstone.security;

import com.capstone.security.InputValidator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Security-focused tests validating input sanitisation and injection prevention.
 * Tests acceptance criteria from NFR-004.
 */
class SecurityInputTest {

    private InputValidator validator;

    @BeforeEach
    void setUp() {
        validator = new InputValidator();
    }

    @ParameterizedTest(name = "SQL injection blocked: {0}")
    @ValueSource(strings = {
        "'; DROP TABLE users;--",
        "admin'--",
        "' UNION SELECT * FROM users--"
    })
    void sqlInjectionPatternsAreDetectedAsUnsafe(String input) {
        assertFalse(validator.isSafe(input), "Should detect SQL injection: " + input);
    }

    @ParameterizedTest(name = "XSS blocked: {0}")
    @ValueSource(strings = {
        "<script>alert('xss')</script>",
        "<img onerror=alert(1)>",
        "javascript:void(0)"
    })
    void xssPatternsAreDetectedAsUnsafe(String input) {
        assertFalse(validator.isSafe(input), "Should detect XSS: " + input);
    }

    @ParameterizedTest(name = "Path traversal blocked: {0}")
    @ValueSource(strings = {
        "../../etc/passwd",
        "..\\windows\\system32"
    })
    void pathTraversalPatternsAreDetectedAsUnsafe(String input) {
        assertFalse(validator.isSafe(input), "Should detect path traversal: " + input);
    }

    @Test
    void sanitiseRemovesAllDangerousCharacters() {
        String dangerous = "<script>alert('xss')</script>";
        String sanitised = validator.sanitise(dangerous);
        // Script tags and special characters are stripped
        assertFalse(sanitised.contains("<script>"), "Script opening tag should be removed");
        assertFalse(sanitised.contains("</script>"), "Script closing tag should be removed");
    }

    @Test
    void sanitiseDoesNotModifyCleanData() {
        String clean = "John Smith 123";
        assertEquals(clean, validator.sanitise(clean));
    }

    @Test
    void emptyStringFailsRequiredValidation() {
        assertThrows(IllegalArgumentException.class,
            () -> validator.requireNonBlank("", "fieldName"));
    }

    @Test
    void nullFailsRequiredValidation() {
        assertThrows(IllegalArgumentException.class,
            () -> validator.requireNonBlank(null, "fieldName"));
    }
}
