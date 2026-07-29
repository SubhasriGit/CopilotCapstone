package com.capstone.service;

import com.capstone.model.AppEntity;
import com.capstone.repository.AppRepository;
import com.capstone.resilience.CircuitBreaker;
import com.capstone.resilience.RetryWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Business logic layer.
 * Delegates data access to AppRepository and external calls to ExternalApiClient.
 * All external dependencies are wrapped in RetryWrapper and CircuitBreaker.
 */
@Service
public class AppService {

    private static final Logger log = LoggerFactory.getLogger(AppService.class);

    private final AppRepository repository;
    private final RetryWrapper retryWrapper;
    private final CircuitBreaker circuitBreaker;

    public AppService(AppRepository repository,
                      RetryWrapper retryWrapper,
                      CircuitBreaker circuitBreaker) {
        this.repository     = repository;
        this.retryWrapper   = retryWrapper;
        this.circuitBreaker = circuitBreaker;
    }

    /** Returns all entities from the data store. */
    public List<AppEntity> findAll() {
        return retryWrapper.execute(repository::findAll, "findAll");
    }

    /** Returns an entity by ID, or empty if not found. */
    public Optional<AppEntity> findById(String id) {
        return retryWrapper.execute(() -> repository.findById(id), "findById");
    }

    /** Creates and persists a new entity. */
    public AppEntity create(AppEntity entity) {
        log.info("Creating new entity with name='{}'", entity.getName());
        return retryWrapper.execute(() -> repository.save(entity), "create");
    }

    /** Updates an existing entity. Throws if not found. */
    public AppEntity update(String id, AppEntity updates) {
        AppEntity existing = repository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Entity not found: " + id));
        existing.setName(updates.getName());
        if (updates.getStatus() != null) {
            existing.setStatus(updates.getStatus());
        }
        log.info("Updating entity id='{}'", id);
        return retryWrapper.execute(() -> repository.save(existing), "update");
    }

    /** Deletes an entity by ID. Throws if not found. */
    public void delete(String id) {
        if (!repository.existsById(id)) {
            throw new IllegalArgumentException("Entity not found: " + id);
        }
        log.info("Deleting entity id='{}'", id);
        retryWrapper.execute(() -> { repository.deleteById(id); return null; }, "delete");
    }
}
