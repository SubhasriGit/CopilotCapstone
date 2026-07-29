package com.capstone.unit;

import com.capstone.api.AppController;
import com.capstone.model.AppEntity;
import com.capstone.security.InputValidator;
import com.capstone.service.AppService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AppControllerTest {

    @Mock private AppService service;
    private AppController controller;

    @BeforeEach
    void setUp() {
        controller = new AppController(service, new InputValidator());
    }

    @Test
    void getAllReturnsOkWithEntities() {
        AppEntity entity = new AppEntity();
        entity.setName("Test");
        when(service.findAll()).thenReturn(List.of(entity));

        ResponseEntity<Map<String, Object>> response = controller.getAll();

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(1, response.getBody().get("total"));
    }

    @Test
    void getByIdReturnsOkWhenFound() {
        AppEntity entity = new AppEntity();
        entity.setName("Found");
        when(service.findById("550e8400-e29b-41d4-a716-446655440000"))
            .thenReturn(Optional.of(entity));

        ResponseEntity<?> response = controller.getById("550e8400-e29b-41d4-a716-446655440000");

        assertEquals(HttpStatus.OK, response.getStatusCode());
    }

    @Test
    void getByIdReturns404WhenNotFound() {
        when(service.findById("550e8400-e29b-41d4-a716-446655440000"))
            .thenReturn(Optional.empty());

        ResponseEntity<?> response = controller.getById("550e8400-e29b-41d4-a716-446655440000");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }

    @Test
    void getByIdReturns400ForInvalidUuid() {
        assertThrows(IllegalArgumentException.class,
            () -> controller.getById("not-a-uuid"));
    }

    @Test
    void createReturns201ForValidInput() {
        AppEntity saved = new AppEntity();
        saved.setName("New Entity");
        when(service.create(any())).thenReturn(saved);

        ResponseEntity<?> response = controller.create(Map.of("name", "New Entity"));

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
    }

    @Test
    void createReturns400WhenNameMissing() {
        assertThrows(IllegalArgumentException.class,
            () -> controller.create(Map.of()));
    }

    @Test
    void deleteReturns204WhenFound() {
        doNothing().when(service).delete("550e8400-e29b-41d4-a716-446655440000");

        ResponseEntity<?> response = controller.delete("550e8400-e29b-41d4-a716-446655440000");

        assertEquals(HttpStatus.NO_CONTENT, response.getStatusCode());
    }

    @Test
    void deleteReturns404WhenNotFound() {
        doThrow(new IllegalArgumentException("not found"))
            .when(service).delete("550e8400-e29b-41d4-a716-446655440000");

        ResponseEntity<?> response = controller.delete("550e8400-e29b-41d4-a716-446655440000");

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }
}
