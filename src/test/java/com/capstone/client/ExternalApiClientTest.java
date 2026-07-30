package com.capstone.client;

import com.capstone.config.ConfigLoader;
import com.capstone.resilience.CircuitBreaker;
import com.capstone.resilience.FallbackHandler;
import com.capstone.resilience.RetryWrapper;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class ExternalApiClientTest {

    private static HttpServer server;
    private static int port;

    @BeforeAll
    static void startServer() throws IOException {
        server = HttpServer.create(new InetSocketAddress(0), 0);
        server.createContext("/hello", ExternalApiClientTest::handleGet);
        server.createContext("/echo", ExternalApiClientTest::handlePost);
        server.start();
        port = server.getAddress().getPort();
    }

    @AfterAll
    static void stopServer() {
        if (server != null) {
            server.stop(0);
        }
    }

    @Test
    void getAndPostUseConfiguredBaseUrl() {
        ConfigLoader config = testConfig("local", "http://127.0.0.1:" + port);
        ExternalApiClient client = new ExternalApiClient(
            config,
            new RetryWrapper(config),
            new CircuitBreaker(config, new FallbackHandler())
        );

        assertEquals("hello", client.get("/hello"));
        assertEquals("echo:payload", client.post("/echo", "payload"));
    }

    @Test
    void rejectsHttpBaseUrlInProduction() {
        ConfigLoader config = testConfig("production", "http://127.0.0.1:" + port);

        assertThrows(IllegalStateException.class, () ->
            new ExternalApiClient(config, new RetryWrapper(config), new CircuitBreaker(config, new FallbackHandler()))
        );
    }

    private static ConfigLoader testConfig(String appEnv, String baseUrl) {
        return new ConfigLoader() {
            @Override
            public String getOrDefault(String key, String defaultValue) {
                return switch (key) {
                    case "APP_ENV" -> appEnv;
                    case "EXTERNAL_API_URL" -> baseUrl;
                    case "EXTERNAL_API_KEY" -> "";
                    default -> defaultValue;
                };
            }

            @Override
            public int getIntOrDefault(String key, int defaultValue) {
                return defaultValue;
            }

            @Override
            public long getLongOrDefault(String key, long defaultValue) {
                return defaultValue;
            }
        };
    }

    private static void handleGet(HttpExchange exchange) throws IOException {
        byte[] body = "hello".getBytes(StandardCharsets.UTF_8);
        exchange.sendResponseHeaders(200, body.length);
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(body);
        }
    }

    private static void handlePost(HttpExchange exchange) throws IOException {
        byte[] request = exchange.getRequestBody().readAllBytes();
        byte[] body = ("echo:" + new String(request, StandardCharsets.UTF_8)).getBytes(StandardCharsets.UTF_8);
        exchange.sendResponseHeaders(200, body.length);
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(body);
        }
    }
}
