package com.capstone.unit;

import com.capstone.model.AppEntity;
import com.capstone.repository.AppRepository;
import com.capstone.resilience.CircuitBreaker;
import com.capstone.resilience.RetryWrapper;
import com.capstone.service.AppService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AppServiceTest {

    @Mock private AppRepository repository;
    @Mock private RetryWrapper retryWrapper;
    @Mock private CircuitBreaker circuitBreaker;

    private AppService service;

    @BeforeEach
    void setUp() {
        // Make RetryWrapper execute the callable directly (no retry needed in unit test)
        lenient().when(retryWrapper.execute(any(), anyString()))
            .thenAnswer(inv -> inv.getArgument(0, java.util.concurrent.Callable.class).call());
        service = new AppService(repository, retryWrapper, circuitBreaker);
    }

    @Test
    void findAllReturnsList() {
        AppEntity entity = new AppEntity();
        entity.setName("Test");
        when(repository.findAll()).thenReturn(List.of(entity));

        List<AppEntity> result = service.findAll();

        assertEquals(1, result.size());
        assertEquals("Test", result.get(0).getName());
    }

    @Test
    void findByIdReturnsEntityWhenFound() {
        AppEntity entity = new AppEntity();
        entity.setName("Found");
        when(repository.findById("test-id")).thenReturn(Optional.of(entity));

        Optional<AppEntity> result = service.findById("test-id");

        assertTrue(result.isPresent());
        assertEquals("Found", result.get().getName());
    }

    @Test
    void findByIdReturnsEmptyWhenNotFound() {
        when(repository.findById("missing-id")).thenReturn(Optional.empty());

        Optional<AppEntity> result = service.findById("missing-id");

        assertFalse(result.isPresent());
    }

    @Test
    void createSavesAndReturnsEntity() {
        AppEntity entity = new AppEntity();
        entity.setName("New");
        when(repository.save(entity)).thenReturn(entity);

        AppEntity result = service.create(entity);

        assertEquals("New", result.getName());
        verify(repository).save(entity);
    }

    @Test
    void updateThrowsWhenEntityNotFound() {
        when(repository.findById("missing")).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
            () -> service.update("missing", new AppEntity()));
    }

    @Test
    void deleteThrowsWhenEntityNotFound() {
        when(repository.existsById("missing")).thenReturn(false);

        assertThrows(IllegalArgumentException.class,
            () -> service.delete("missing"));
    }

    @Test
    void deleteCallsRepositoryWhenFound() {
        when(repository.existsById("valid-id")).thenReturn(true);
        doNothing().when(repository).deleteById("valid-id");

        assertDoesNotThrow(() -> service.delete("valid-id"));
        verify(repository).deleteById("valid-id");
    }
}
