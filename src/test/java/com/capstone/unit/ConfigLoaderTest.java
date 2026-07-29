package com.capstone.unit;

import com.capstone.config.ConfigLoader;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ConfigLoaderTest {

    private ConfigLoader configLoader;

    @BeforeEach
    void setUp() {
        configLoader = new ConfigLoader();
    }

    @Test
    void getReturnsNullWhenEnvVarNotSet() {
        assertNull(configLoader.get("__NON_EXISTENT_VAR_XYZ__"));
    }

    @Test
    void getRequiredThrowsWhenEnvVarNotSet() {
        IllegalStateException ex = assertThrows(IllegalStateException.class,
            () -> configLoader.getRequired("__NON_EXISTENT_VAR_XYZ__"));
        assertTrue(ex.getMessage().contains("__NON_EXISTENT_VAR_XYZ__"));
    }

    @Test
    void getOrDefaultReturnsDefaultWhenNotSet() {
        assertEquals("fallback", configLoader.getOrDefault("__NON_EXISTENT_VAR_XYZ__", "fallback"));
    }

    @Test
    void getIntOrDefaultReturnsDefaultWhenNotSet() {
        assertEquals(42, configLoader.getIntOrDefault("__NON_EXISTENT_VAR_XYZ__", 42));
    }

    @Test
    void getLongOrDefaultReturnsDefaultWhenNotSet() {
        assertEquals(1000L, configLoader.getLongOrDefault("__NON_EXISTENT_VAR_XYZ__", 1000L));
    }
}
