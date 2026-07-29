# API Reference

Base path: `/api/v1`

## Health
### GET /health
Returns system health.

**200**
```json
{
  "status": "UP",
  "timestamp": "2026-07-28T15:00:00Z",
  "connections": { "externalApi": "UP" },
  "circuitBreaker": "CLOSED"
}
```

**503**
```json
{
  "status": "DEGRADED",
  "timestamp": "2026-07-28T15:00:00Z"
}
```

## Entities
### GET /entities
Returns all entities.

### GET /entities/{id}
Returns one entity by UUID.

### POST /entities
Creates an entity.

Request:
```json
{ "name": "Example" }
```

### PUT /entities/{id}
Updates an entity.

### DELETE /entities/{id}
Deletes an entity.

## Error format
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Human readable message",
  "timestamp": "2026-07-28T15:00:00Z"
}
```

