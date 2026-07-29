package com.capstone.api;

import com.capstone.model.AppEntity;
import com.capstone.security.InputValidator;
import com.capstone.service.AppService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * REST controller for AppEntity CRUD operations.
 * Validates all input before delegating to AppService.
 */
@RestController
@RequestMapping("/api/v1/entities")
public class AppController {

    private final AppService service;
    private final InputValidator validator;

    public AppController(AppService service, InputValidator validator) {
        this.service   = service;
        this.validator = validator;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAll() {
        List<AppEntity> entities = service.findAll();
        return ResponseEntity.ok(Map.of("data", entities, "total", entities.size()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable String id) {
        validator.requireValidUuid(id, "id");
        Optional<AppEntity> entity = service.findById(id);
        return entity
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElseGet(() -> notFound("Entity with id '" + id + "' not found"));
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, String> body) {
        String name = body.get("name");
        validator.requireNonBlank(name, "name");
        validator.requireMaxLength(name, "name", 255);

        AppEntity entity = new AppEntity();
        entity.setName(validator.sanitise(name));

        AppEntity created = service.create(entity);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable String id, @RequestBody Map<String, String> body) {
        validator.requireValidUuid(id, "id");

        AppEntity updates = new AppEntity();
        String name = body.get("name");
        if (name != null) {
            validator.requireMaxLength(name, "name", 255);
            updates.setName(validator.sanitise(name));
        }
        String statusStr = body.get("status");
        if (statusStr != null) {
            try {
                updates.setStatus(AppEntity.Status.valueOf(statusStr.toUpperCase()));
            } catch (IllegalArgumentException e) {
                return badRequest("Invalid status value: " + statusStr);
            }
        }

        try {
            return ResponseEntity.ok(service.update(id, updates));
        } catch (IllegalArgumentException e) {
            return notFound(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable String id) {
        validator.requireValidUuid(id, "id");
        try {
            service.delete(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return notFound(e.getMessage());
        }
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleValidationError(IllegalArgumentException ex) {
        return ResponseEntity.badRequest().body(errorBody("VALIDATION_ERROR", ex.getMessage()));
    }

    private ResponseEntity<Map<String, Object>> notFound(String message) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorBody("NOT_FOUND", message));
    }

    private ResponseEntity<Map<String, Object>> badRequest(String message) {
        return ResponseEntity.badRequest().body(errorBody("VALIDATION_ERROR", message));
    }

    private Map<String, Object> errorBody(String code, String message) {
        return Map.of("error", code, "message", message, "timestamp", Instant.now().toString());
    }
}
