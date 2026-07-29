package com.capstone.resilience;

/**
 * Possible states of a CircuitBreaker.
 */
public enum CircuitBreakerState {
    /** Normal operation — calls pass through. */
    CLOSED,
    /** Too many failures — calls are blocked and fallback is returned immediately. */
    OPEN,
    /** Cooldown elapsed — one test call is allowed to check if service recovered. */
    HALF_OPEN
}
