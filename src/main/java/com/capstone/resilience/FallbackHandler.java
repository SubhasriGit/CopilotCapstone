package com.capstone.resilience;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Provides safe fallback responses when a circuit is OPEN or retries are exhausted.
 * Every fallback is logged so it can be tracked and investigated.
 */
@Component
public class FallbackHandler {

    private static final Logger log = LoggerFactory.getLogger(FallbackHandler.class);

    /**
     * Returns a safe fallback for the given operation.
     * The return type is intentionally generic — callers cast to the expected type.
     */
    @SuppressWarnings("unchecked")
    public <T> T getFallbackResponse(String operationName) {
        log.warn("Fallback invoked for operation '{}'. Returning safe default.", operationName);
        // Returns null — callers are responsible for handling a null fallback gracefully.
        // Specific fallbacks should be registered per operation as the system grows.
        return null;
    }

    /**
     * Returns a descriptive fallback message for use in API error responses.
     */
    public String getFallbackMessage(String operationName) {
        log.warn("Fallback message requested for operation '{}'", operationName);
        return "Service temporarily unavailable for operation: " + operationName +
               ". Please try again later.";
    }
}
