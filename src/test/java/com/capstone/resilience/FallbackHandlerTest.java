package com.capstone.resilience;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class FallbackHandlerTest {

    private FallbackHandler fallbackHandler;

    @BeforeEach
    void setUp() {
        fallbackHandler = new FallbackHandler();
    }

    @Test
    void getFallbackResponseReturnsNull() {
        Object result = fallbackHandler.getFallbackResponse("someOperation");
        assertNull(result);
    }

    @Test
    void getFallbackMessageContainsOperationName() {
        String msg = fallbackHandler.getFallbackMessage("getUserData");
        assertTrue(msg.contains("getUserData"));
    }

    @Test
    void getFallbackResponseDoesNotThrow() {
        assertDoesNotThrow(() -> fallbackHandler.getFallbackResponse("anyOp"));
    }
}
