package com.capstone.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Loads all configuration from environment variables.
 * Never reads secrets from hardcoded values or config files.
 */
@Component
public class ConfigLoader {

    private static final Logger log = LoggerFactory.getLogger(ConfigLoader.class);

    /** Returns the value of an env var, or null if not set. */
    public String get(String key) {
        return System.getenv(key);
    }

    /**
     * Returns the value of a required env var.
     * Throws IllegalStateException if the variable is not set.
     */
    public String getRequired(String key) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException(
                "Required environment variable '" + key + "' is not set. " +
                "Set it before starting the application."
            );
        }
        return value;
    }

    /** Returns the value of an env var with a fallback default (safe for non-secrets). */
    public String getOrDefault(String key, String defaultValue) {
        String value = System.getenv(key);
        return (value != null && !value.isBlank()) ? value : defaultValue;
    }

    /** Returns an integer env var with a fallback default. */
    public int getIntOrDefault(String key, int defaultValue) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) return defaultValue;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            log.warn("Env var '{}' has non-integer value '{}'. Using default: {}", key, value, defaultValue);
            return defaultValue;
        }
    }

    /** Returns a long env var with a fallback default. */
    public long getLongOrDefault(String key, long defaultValue) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) return defaultValue;
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            log.warn("Env var '{}' has non-integer value '{}'. Using default: {}", key, value, defaultValue);
            return defaultValue;
        }
    }
}
