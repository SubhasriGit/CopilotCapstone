package com.capstone.resilience;

/**
 * Thrown when all retry attempts have been exhausted without success.
 */
public class RetryExhaustedException extends RuntimeException {

    private final int attempts;

    public RetryExhaustedException(String message, int attempts, Throwable cause) {
        super(message, cause);
        this.attempts = attempts;
    }

    public int getAttempts() {
        return attempts;
    }
}
