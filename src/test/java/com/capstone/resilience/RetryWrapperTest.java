package com.capstone.resilience;

import com.capstone.config.ConfigLoader;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.concurrent.Callable;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

class RetryWrapperTest {

    private RetryWrapper retryWrapper;

    @BeforeEach
    void setUp() {
        // Use very short delays and 3 max attempts for fast tests
        ConfigLoader config = new ConfigLoader() {
            @Override public int getIntOrDefault(String key, int def) {
                return "RETRY_MAX_ATTEMPTS".equals(key) ? 3 : def;
            }
            @Override public long getLongOrDefault(String key, long def) {
                return "RETRY_BASE_DELAY_MS".equals(key) ? 1L : def; // 1ms for fast tests
            }
        };
        retryWrapper = new RetryWrapper(config);
    }

    @Test
    void executeSucceedsOnFirstAttempt() throws Exception {
        String result = retryWrapper.execute(() -> "success", "testOp");
        assertEquals("success", result);
    }

    @Test
    void executeRetriesAndSucceedsOnThirdAttempt() {
        AtomicInteger attempts = new AtomicInteger(0);

        String result = retryWrapper.execute(() -> {
            if (attempts.incrementAndGet() < 3) throw new RuntimeException("transient");
            return "recovered";
        }, "testOp");

        assertEquals("recovered", result);
        assertEquals(3, attempts.get());
    }

    @Test
    void executeThrowsRetryExhaustedAfterAllAttemptsFail() {
        Callable<String> alwaysFails = () -> { throw new RuntimeException("permanent"); };

        RetryExhaustedException ex = assertThrows(RetryExhaustedException.class,
            () -> retryWrapper.execute(alwaysFails, "testOp"));

        assertEquals(3, ex.getAttempts());
        assertTrue(ex.getMessage().contains("testOp"));
    }

    @Test
    void executeReturnsNullForVoidOperations() {
        assertDoesNotThrow(() -> retryWrapper.execute(() -> null, "voidOp"));
    }
}
