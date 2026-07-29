package com.capstone.health;

import com.capstone.resilience.CircuitBreaker;
import com.capstone.resilience.CircuitBreakerState;
import com.capstone.security.ConnectionValidator;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

/**
 * Exposes /health endpoint for monitoring and deployment validation.
 * Returns 200 OK when healthy, 503 when degraded.
 */
@RestController
@RequestMapping("/health")
public class HealthController {

    private final ConnectionValidator connectionValidator;
    private final CircuitBreaker circuitBreaker;

    public HealthController(ConnectionValidator connectionValidator,
                            CircuitBreaker circuitBreaker) {
        this.connectionValidator = connectionValidator;
        this.circuitBreaker      = circuitBreaker;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, String> connections = connectionValidator.getConnectionStatuses();
        CircuitBreakerState cbState = circuitBreaker.getState();

        boolean degraded = connections.values().stream().anyMatch("DOWN"::equals)
                        || cbState == CircuitBreakerState.OPEN;

        Map<String, Object> body = Map.of(
            "status",        degraded ? "DEGRADED" : "UP",
            "timestamp",     Instant.now().toString(),
            "connections",   connections,
            "circuitBreaker", cbState.name()
        );

        HttpStatus status = degraded ? HttpStatus.SERVICE_UNAVAILABLE : HttpStatus.OK;
        return ResponseEntity.status(status).body(body);
    }
}
