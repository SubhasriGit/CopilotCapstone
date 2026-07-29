package com.capstone.security;

import com.capstone.config.ConfigLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Validates that all required external connections are reachable.
 * Called at application startup and by the pre-commit hook.
 */
@Component
public class ConnectionValidator {

    private static final Logger log = LoggerFactory.getLogger(ConnectionValidator.class);
    private static final int TIMEOUT_MS = 5000;

    private final ConfigLoader config;

    public ConnectionValidator(ConfigLoader config) {
        this.config = config;
    }

    /**
     * Validates all configured connections.
     * Throws IllegalStateException if any critical connection is unreachable.
     */
    public void validateAll() {
        Map<String, Boolean> results = new LinkedHashMap<>();

        String externalApiUrl = config.get("EXTERNAL_API_URL");
        if (externalApiUrl != null && !externalApiUrl.isBlank()) {
            results.put("EXTERNAL_API", validateConnection("External API", externalApiUrl));
        }

        boolean allCriticalUp = results.values().stream().allMatch(Boolean::booleanValue);
        if (!allCriticalUp) {
            throw new IllegalStateException(
                "One or more critical connections are unreachable. Check logs for details."
            );
        }
        log.info("All connection checks passed.");
    }

    /**
     * Validates a single HTTP/HTTPS connection.
     * Returns true if reachable, false otherwise.
     */
    public boolean validateConnection(String name, String url) {
        try {
            URL target = URI.create(url).toURL();
            HttpURLConnection conn = (HttpURLConnection) target.openConnection();
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);
            conn.setRequestMethod("HEAD");
            int responseCode = conn.getResponseCode();
            boolean reachable = responseCode < 500;
            if (reachable) {
                log.info("Connection '{}' at '{}' is reachable (HTTP {})", name, url, responseCode);
            } else {
                log.error("Connection '{}' at '{}' returned HTTP {} — treating as unreachable", name, url, responseCode);
            }
            return reachable;
        } catch (IOException e) {
            log.error("Connection '{}' at '{}' is unreachable: {}", name, url, e.getMessage());
            return false;
        }
    }

    /**
     * Returns a map of all connection statuses (name → reachable).
     * Used by the health endpoint.
     */
    public Map<String, String> getConnectionStatuses() {
        Map<String, String> statuses = new LinkedHashMap<>();

        String externalApiUrl = config.get("EXTERNAL_API_URL");
        if (externalApiUrl != null && !externalApiUrl.isBlank()) {
            statuses.put("externalApi",
                validateConnection("External API", externalApiUrl) ? "UP" : "DOWN");
        }

        return statuses;
    }
}
