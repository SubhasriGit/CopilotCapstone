package com.capstone.client;

import com.capstone.config.ConfigLoader;
import com.capstone.resilience.CircuitBreaker;
import com.capstone.resilience.RetryWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * HTTP client for all external API calls.
 * Every call is wrapped in RetryWrapper and CircuitBreaker.
 * API base URL and key are read from environment variables — never hardcoded.
 */
@Component
public class ExternalApiClient {

    private static final Logger log = LoggerFactory.getLogger(ExternalApiClient.class);

    private final WebClient webClient;
    private final RetryWrapper retryWrapper;
    private final CircuitBreaker circuitBreaker;

    public ExternalApiClient(ConfigLoader config,
                             RetryWrapper retryWrapper,
                             CircuitBreaker circuitBreaker) {
        String baseUrl = config.getOrDefault("EXTERNAL_API_URL", "https://api.example.com");
        String appEnv  = config.getOrDefault("APP_ENV", "local");

        // Enforce HTTPS in non-local environments when a custom endpoint is configured.
        if (!"local".equalsIgnoreCase(appEnv) && baseUrl.startsWith("http://")) {
            throw new IllegalStateException(
                "EXTERNAL_API_URL must use HTTPS in non-local environments (APP_ENV=" + appEnv + ")."
            );
        }

        String apiKey  = config.getOrDefault("EXTERNAL_API_KEY", "");

        this.webClient = WebClient.builder()
            .baseUrl(baseUrl)
            .defaultHeader("X-API-Key", apiKey)  // key from env var
            .build();

        this.retryWrapper    = retryWrapper;
        this.circuitBreaker  = circuitBreaker;
    }

    /**
     * Performs a GET request to the given path.
     * Wrapped in retry + circuit breaker for self-healing.
     */
    public String get(String path) {
        return circuitBreaker.call(
            () -> retryWrapper.execute(
                () -> webClient.get()
                        .uri(path)
                        .retrieve()
                        .bodyToMono(String.class)
                        .block(),
                "GET " + path
            ),
            "ExternalApi.GET"
        );
    }

    /**
     * Performs a POST request with the given body.
     * Wrapped in retry + circuit breaker for self-healing.
     */
    public String post(String path, String body) {
        return circuitBreaker.call(
            () -> retryWrapper.execute(
                () -> webClient.post()
                        .uri(path)
                        .bodyValue(body)
                        .retrieve()
                        .bodyToMono(String.class)
                        .block(),
                "POST " + path
            ),
            "ExternalApi.POST"
        );
    }
}
