package com.capstone.repository;

import com.capstone.model.AppEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Data access layer for AppEntity.
 * Connection string is supplied via DB_URL environment variable — never hardcoded.
 */
@Repository
public interface AppRepository extends JpaRepository<AppEntity, String> {

    List<AppEntity> findByStatus(AppEntity.Status status);
}
