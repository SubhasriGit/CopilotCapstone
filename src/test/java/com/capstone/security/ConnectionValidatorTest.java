package com.capstone.security;

import com.capstone.config.ConfigLoader;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ConnectionValidatorTest {

    private ConnectionValidator validator;

    @BeforeEach
    void setUp() {
        // No EXTERNAL_API_URL set — validateAll should pass (nothing to check)
        validator = new ConnectionValidator(new ConfigLoader());
    }

    @Test
    void validateAllPassesWhenNoConnectionsConfigured() {
        // With no env vars set, there are no connections to validate — should pass silently
        assertDoesNotThrow(() -> validator.validateAll());
    }

    @Test
    void validateConnectionReturnsFalseForUnreachableHost() {
        boolean reachable = validator.validateConnection("Test", "http://localhost:19999");
        assertFalse(reachable, "Should return false for unreachable host");
    }

    @Test
    void getConnectionStatusesReturnsEmptyMapWhenNotConfigured() {
        var statuses = validator.getConnectionStatuses();
        assertTrue(statuses.isEmpty(), "Should have no statuses when no connections configured");
    }
}
