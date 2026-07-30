package com.capstone.api;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class WelcomeController {

    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> welcome() {
        return ResponseEntity.ok(Map.of(
            "message", "OfficeCheck API - GitHub Copilot Capstone",
            "version", "1.0.0-SNAPSHOT",
            "endpoints", Map.of(
                "health", "/health",
                "entities", "/api/v1/entities",
                "actuator", "/actuator"
            )
        ));
    }
}
