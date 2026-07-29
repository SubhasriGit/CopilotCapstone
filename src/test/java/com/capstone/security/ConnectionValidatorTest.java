package com.capstone.security;

import com.capstone.config.ConfigLoader;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class ConnectionValidatorTest {

    @Mock
    private ConfigLoader config;

    @Test
    void validateAllPassesWhenNoConnectionsConfigured() {
        // Return null for EXTERNAL_API_URL → no connections to check → should pass
        Mockito.when(config.get("EXTERNAL_API_URL")).thenReturn(null);
        ConnectionValidator validator = new ConnectionValidator(config);
        assertDoesNotThrow(() -> validator.validateAll());
    }

    @Test
    void validateConnectionReturnsFalseForUnreachableHost() {
        // Uses real ConfigLoader — calls validateConnection directly, no env-var dependency
        ConnectionValidator validator = new ConnectionValidator(new ConfigLoader());
        boolean reachable = validator.validateConnection("Test", "http://localhost:19999");
        assertFalse(reachable, "Should return false for unreachable host");
    }

    @Test
    void getConnectionStatusesReturnsEmptyMapWhenNotConfigured() {
        // Return null → no connections registered → empty statuses map
        Mockito.when(config.get("EXTERNAL_API_URL")).thenReturn(null);
        ConnectionValidator validator = new ConnectionValidator(config);
        var statuses = validator.getConnectionStatuses();
        assertTrue(statuses.isEmpty(), "Should have no statuses when no connections configured");
    }
}
