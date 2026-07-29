package com.capstone.resilience;

import com.capstone.config.ConfigLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.concurrent.Callable;

/**
 * Wraps any callable with retry logic using exponential backoff.
 * Config via env vars: RETRY_MAX_ATTEMPTS, RETRY_BASE_DELAY_MS
 */
@Component
public class RetryWrapper {

    private static final Logger log = LoggerFactory.getLogger(RetryWrapper.class);

    private final int maxAttempts;
    private final long baseDelayMs;

    public RetryWrapper(ConfigLoader config) {
        this.maxAttempts = config.getIntOrDefault("RETRY_MAX_ATTEMPTS", 3);
        this.baseDelayMs = config.getLongOrDefault("RETRY_BASE_DELAY_MS", 1000L);
    }

    /**
     * Executes the given task with retry and exponential backoff.
     * Delay formula: baseDelayMs * 2^(attempt - 1)
     *
     * @throws RetryExhaustedException if all attempts fail
     */
    public <T> T execute(Callable<T> task, String operationName) {
        Exception lastException = null;

        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                T result = task.call();
                if (attempt > 1) {
                    log.info("Operation '{}' succeeded on attempt {}/{}", operationName, attempt, maxAttempts);
                }
                return result;
            } catch (Exception e) {
                lastException = e;
                log.warn("Operation '{}' failed on attempt {}/{}: {}", operationName, attempt, maxAttempts, e.getMessage());

                if (attempt < maxAttempts) {
                    long delay = baseDelayMs * (long) Math.pow(2, attempt - 1);
                    log.info("Retrying '{}' in {}ms...", operationName, delay);
                    sleep(delay);
                }
            }
        }

        throw new RetryExhaustedException(
            "Operation '" + operationName + "' failed after " + maxAttempts + " attempts",
            maxAttempts,
            lastException
        );
    }

    private void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException ie) {
            Thread.currentThread().interrupt();
        }
    }
}
