package com.capstone.unit;

import com.capstone.security.InputValidator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.*;

class InputValidatorTest {

    private InputValidator validator;

    @BeforeEach
    void setUp() {
        validator = new InputValidator();
    }

    // --- requireNonBlank ---

    @Test
    void requireNonBlankPassesForValidString() {
        assertDoesNotThrow(() -> validator.requireNonBlank("hello", "field"));
    }

    @Test
    void requireNonBlankThrowsForNull() {
        assertThrows(IllegalArgumentException.class,
            () -> validator.requireNonBlank(null, "field"));
    }

    @Test
    void requireNonBlankThrowsForBlank() {
        assertThrows(IllegalArgumentException.class,
            () -> validator.requireNonBlank("   ", "field"));
    }

    // --- requireMaxLength ---

    @Test
    void requireMaxLengthPassesUnderLimit() {
        assertDoesNotThrow(() -> validator.requireMaxLength("hello", "field", 10));
    }

    @Test
    void requireMaxLengthThrowsOverLimit() {
        assertThrows(IllegalArgumentException.class,
            () -> validator.requireMaxLength("toolongvalue", "field", 5));
    }

    // --- requireValidUuid ---

    @Test
    void requireValidUuidPassesForValidUuid() {
        assertDoesNotThrow(() ->
            validator.requireValidUuid("550e8400-e29b-41d4-a716-446655440000", "id"));
    }

    @Test
    void requireValidUuidThrowsForInvalidUuid() {
        assertThrows(IllegalArgumentException.class,
            () -> validator.requireValidUuid("not-a-uuid", "id"));
    }

    // --- sanitise ---

    @Test
    void sanitiseRemovesScriptTags() {
        String result = validator.sanitise("<script>alert('xss')</script>");
        assertFalse(result.contains("<script>"));
    }

    @Test
    void sanitiseReturnsNullForNull() {
        assertNull(validator.sanitise(null));
    }

    @Test
    void sanitisePreservesCleanInput() {
        assertEquals("hello world", validator.sanitise("hello world"));
    }

    // --- isSafe ---

    @ParameterizedTest
    @ValueSource(strings = {"'; DROP TABLE users;--", "<script>", "../etc/passwd", "javascript:void"})
    void isSafeReturnsFalseForDangerousInput(String dangerous) {
        assertFalse(validator.isSafe(dangerous));
    }

    @Test
    void isSafeReturnsTrueForCleanInput() {
        assertTrue(validator.isSafe("Clean input 123"));
    }

    @Test
    void isSafeReturnsTrueForNull() {
        assertTrue(validator.isSafe(null));
    }
}
