package com.capstone.resilience;

import com.capstone.config.ConfigLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.concurrent.Callable;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Circuit breaker that transitions between CLOSED → OPEN → HALF_OPEN states.
 * Config via env vars: CB_FAILURE_THRESHOLD, CB_RESET_TIMEOUT_MS
 */
@Component
public class CircuitBreaker {

    private static final Logger log = LoggerFactory.getLogger(CircuitBreaker.class);

    private final int failureThreshold;
    private final long resetTimeoutMs;
    private final FallbackHandler fallbackHandler;

    private final AtomicReference<CircuitBreakerState> state =
        new AtomicReference<>(CircuitBreakerState.CLOSED);
    private final AtomicInteger failureCount = new AtomicInteger(0);
    private final AtomicLong openedAt = new AtomicLong(0);

    public CircuitBreaker(ConfigLoader config, FallbackHandler fallbackHandler) {
        this.failureThreshold = config.getIntOrDefault("CB_FAILURE_THRESHOLD", 3);
        this.resetTimeoutMs   = config.getLongOrDefault("CB_RESET_TIMEOUT_MS", 30_000L);
        this.fallbackHandler  = fallbackHandler;
    }

    /**
     * Executes the task through the circuit breaker.
     * Returns fallback immediately if circuit is OPEN.
     */
    public <T> T call(Callable<T> task, String operationName) {
        CircuitBreakerState current = state.get();

        if (current == CircuitBreakerState.OPEN) {
            if (System.currentTimeMillis() - openedAt.get() >= resetTimeoutMs) {
                log.info("Circuit '{}' transitioning OPEN → HALF_OPEN", operationName);
                state.set(CircuitBreakerState.HALF_OPEN);
            } else {
                log.warn("Circuit '{}' is OPEN — returning fallback", operationName);
                return fallbackHandler.getFallbackResponse(operationName);
            }
        }

        try {
            T result = task.call();
            onSuccess(operationName);
            return result;
        } catch (Exception e) {
            onFailure(operationName, e);
            return fallbackHandler.getFallbackResponse(operationName);
        }
    }

    private void onSuccess(String operationName) {
        failureCount.set(0);
        if (state.getAndSet(CircuitBreakerState.CLOSED) != CircuitBreakerState.CLOSED) {
            log.info("Circuit '{}' recovered — transitioning to CLOSED", operationName);
        }
    }

    private void onFailure(String operationName, Exception e) {
        int failures = failureCount.incrementAndGet();
        log.warn("Circuit '{}' failure {}/{}: {}", operationName, failures, failureThreshold, e.getMessage());
        if (failures >= failureThreshold) {
            state.set(CircuitBreakerState.OPEN);
            openedAt.set(System.currentTimeMillis());
            log.error("Circuit '{}' opened after {} failures. Will retry in {}ms",
                operationName, failures, resetTimeoutMs);
        }
    }

    public CircuitBreakerState getState() {
        return state.get();
    }

    public void reset() {
        state.set(CircuitBreakerState.CLOSED);
        failureCount.set(0);
        log.info("Circuit breaker manually reset to CLOSED");
    }
}
