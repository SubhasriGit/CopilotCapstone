package com.capstone.resilience;

import com.capstone.config.ConfigLoader;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class CircuitBreakerTest {

    private CircuitBreaker circuitBreaker;
    private FallbackHandler fallbackHandler;

    @BeforeEach
    void setUp() {
        ConfigLoader config = new ConfigLoader() {
            @Override public int getIntOrDefault(String key, int def) {
                return "CB_FAILURE_THRESHOLD".equals(key) ? 3 : def;
            }
            @Override public long getLongOrDefault(String key, long def) {
                // Very short reset timeout for tests
                return "CB_RESET_TIMEOUT_MS".equals(key) ? 100L : def;
            }
        };
        fallbackHandler = new FallbackHandler();
        circuitBreaker = new CircuitBreaker(config, fallbackHandler);
    }

    @Test
    void initialStateIsClosed() {
        assertEquals(CircuitBreakerState.CLOSED, circuitBreaker.getState());
    }

    @Test
    void successfulCallKeepsCircuitClosed() {
        circuitBreaker.call(() -> "ok", "op");
        assertEquals(CircuitBreakerState.CLOSED, circuitBreaker.getState());
    }

    @Test
    void circuitOpensAfterThresholdFailures() {
        for (int i = 0; i < 3; i++) {
            circuitBreaker.call(() -> { throw new RuntimeException("fail"); }, "op");
        }
        assertEquals(CircuitBreakerState.OPEN, circuitBreaker.getState());
    }

    @Test
    void openCircuitReturnsFallbackWithoutCallingTask() {
        // Open the circuit
        for (int i = 0; i < 3; i++) {
            circuitBreaker.call(() -> { throw new RuntimeException("fail"); }, "op");
        }
        assertEquals(CircuitBreakerState.OPEN, circuitBreaker.getState());

        // Subsequent calls return fallback immediately
        int[] taskCallCount = {0};
        Object result = circuitBreaker.call(() -> { taskCallCount[0]++; return "should not be called"; }, "op");

        assertEquals(0, taskCallCount[0], "Task should not be called when circuit is OPEN");
        assertNull(result); // fallback returns null by default
    }

    @Test
    void circuitTransitionsToHalfOpenAfterResetTimeout() throws InterruptedException {
        // Open the circuit
        for (int i = 0; i < 3; i++) {
            circuitBreaker.call(() -> { throw new RuntimeException("fail"); }, "op");
        }
        assertEquals(CircuitBreakerState.OPEN, circuitBreaker.getState());

        // Wait for reset timeout (100ms in test config)
        Thread.sleep(150);

        // Next call should transition to HALF_OPEN and attempt the call
        circuitBreaker.call(() -> "recovered", "op");
        assertEquals(CircuitBreakerState.CLOSED, circuitBreaker.getState());
    }

    @Test
    void manualResetRestoresClosedState() {
        for (int i = 0; i < 3; i++) {
            circuitBreaker.call(() -> { throw new RuntimeException("fail"); }, "op");
        }
        assertEquals(CircuitBreakerState.OPEN, circuitBreaker.getState());

        circuitBreaker.reset();

        assertEquals(CircuitBreakerState.CLOSED, circuitBreaker.getState());
    }

    @Test
    void successAfterFailuresResetsFailureCount() {
        // Two failures
        for (int i = 0; i < 2; i++) {
            circuitBreaker.call(() -> { throw new RuntimeException("fail"); }, "op");
        }
        // Success resets count
        circuitBreaker.call(() -> "ok", "op");
        assertEquals(CircuitBreakerState.CLOSED, circuitBreaker.getState());

        // One more failure shouldn't open circuit (count was reset)
        circuitBreaker.call(() -> { throw new RuntimeException("fail"); }, "op");
        assertEquals(CircuitBreakerState.CLOSED, circuitBreaker.getState());
    }
}
