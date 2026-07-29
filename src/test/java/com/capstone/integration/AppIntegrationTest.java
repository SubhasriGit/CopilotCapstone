package com.capstone.integration;

import com.capstone.repository.AppRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration tests — starts full Spring context with in-memory H2 database.
 * Each test gets a fresh context to prevent shared state pollution.
 */
@SpringBootTest
@AutoConfigureMockMvc
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class AppIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private AppRepository appRepository;

    @BeforeEach
    void cleanDatabase() {
        appRepository.deleteAll();
    }

    @Test
    void healthEndpointReturnsUp() throws Exception {
        mockMvc.perform(get("/health"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("UP"));
    }

    @Test
    void getAllEntitiesReturnsEmptyListInitially() throws Exception {
        mockMvc.perform(get("/api/v1/entities"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.total").value(0))
            .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    void createEntityReturns201() throws Exception {
        mockMvc.perform(post("/api/v1/entities")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\": \"Integration Test Entity\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("Integration Test Entity"))
            .andExpect(jsonPath("$.id").isNotEmpty())
            .andExpect(jsonPath("$.status").value("ACTIVE"));
    }

    @Test
    void createAndGetEntityById() throws Exception {
        // Create
        String response = mockMvc.perform(post("/api/v1/entities")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\": \"Fetch Test\"}"))
            .andExpect(status().isCreated())
            .andReturn().getResponse().getContentAsString();

        // Extract ID from response
        String id = response.replaceAll(".*\"id\":\"([^\"]+)\".*", "$1");

        // Fetch by ID
        mockMvc.perform(get("/api/v1/entities/" + id))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Fetch Test"));
    }

    @Test
    void getByInvalidUuidReturns400() throws Exception {
        mockMvc.perform(get("/api/v1/entities/not-a-uuid"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    @Test
    void createWithMissingNameReturns400() throws Exception {
        mockMvc.perform(post("/api/v1/entities")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    @Test
    void getByNonExistentIdReturns404() throws Exception {
        mockMvc.perform(get("/api/v1/entities/550e8400-e29b-41d4-a716-446655440000"))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.error").value("NOT_FOUND"));
    }

    @Test
    void deleteNonExistentEntityReturns404() throws Exception {
        mockMvc.perform(delete("/api/v1/entities/550e8400-e29b-41d4-a716-446655440000"))
            .andExpect(status().isNotFound());
    }

    @Test
    void createAndDeleteEntity() throws Exception {
        // Create
        String response = mockMvc.perform(post("/api/v1/entities")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\": \"Delete Test\"}"))
            .andExpect(status().isCreated())
            .andReturn().getResponse().getContentAsString();

        String id = response.replaceAll(".*\"id\":\"([^\"]+)\".*", "$1");

        // Delete
        mockMvc.perform(delete("/api/v1/entities/" + id))
            .andExpect(status().isNoContent());

        // Verify gone
        mockMvc.perform(get("/api/v1/entities/" + id))
            .andExpect(status().isNotFound());
    }
}
