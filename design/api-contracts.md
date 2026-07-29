# API Contracts

**Project:** GIthubCopilotCapstone  
**Document:** API Contracts  
**Base URL:** `http://localhost:${APP_PORT}/api/v1`  
**Note:** Business-specific endpoints will be added once Confluence requirements (OQ-001, OQ-003) are resolved.

---

## 1. Health Endpoint

### GET /health
**Description:** Returns application health status.

**Request:** No parameters required.

**Response — Healthy (200 OK):**
```json
{
  "status": "UP",
  "timestamp": "2026-07-28T15:00:00Z",
  "connections": {
    "database": "UP",
    "externalApi": "UP"
  }
}
```

**Response — Degraded (503 Service Unavailable):**
```json
{
  "status": "DEGRADED",
  "timestamp": "2026-07-28T15:00:00Z",
  "connections": {
    "database": "UP",
    "externalApi": "DOWN"
  },
  "message": "External API circuit breaker is OPEN"
}
```

---

## 2. Application Endpoints (Placeholder — update from Confluence)

### GET /api/v1/entities
**Description:** Retrieve all entities. *(Domain name TBD from OQ-001)*

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer $TOKEN  ← from env var, never hardcoded
```

**Response — 200 OK:**
```json
{
  "data": [
    {
      "id": "uuid-here",
      "name": "string",
      "status": "ACTIVE",
      "createdAt": "2026-07-28T15:00:00Z"
    }
  ],
  "total": 1
}
```

---

### GET /api/v1/entities/{id}
**Description:** Retrieve a single entity by ID.

**Path Parameters:**
| Parameter | Type   | Required | Description  |
|-----------|--------|----------|--------------|
| id        | String | Yes      | Entity UUID  |

**Response — 200 OK:**
```json
{
  "id": "uuid-here",
  "name": "string",
  "status": "ACTIVE",
  "createdAt": "2026-07-28T15:00:00Z",
  "updatedAt": "2026-07-28T15:00:00Z"
}
```

**Response — 404 Not Found:**
```json
{
  "error": "NOT_FOUND",
  "message": "Entity with id 'uuid-here' not found"
}
```

---

### POST /api/v1/entities
**Description:** Create a new entity.

**Request Body:**
```json
{
  "name": "string"
}
```

**Validation Rules:**
- `name`: required, non-empty, max 255 characters

**Response — 201 Created:**
```json
{
  "id": "uuid-here",
  "name": "string",
  "status": "ACTIVE",
  "createdAt": "2026-07-28T15:00:00Z"
}
```

**Response — 400 Bad Request:**
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Field 'name' is required"
}
```

---

### PUT /api/v1/entities/{id}
**Description:** Update an existing entity.

**Request Body:**
```json
{
  "name": "string",
  "status": "INACTIVE"
}
```

**Response — 200 OK:** Updated entity object (same as GET response)

**Response — 404 Not Found:** Same as GET 404 format

---

### DELETE /api/v1/entities/{id}
**Description:** Delete an entity by ID.

**Response — 204 No Content:** Empty body on success

**Response — 404 Not Found:** Same as GET 404 format

---

## 3. Standard Error Response Format

All error responses follow this structure:
```json
{
  "error": "ERROR_CODE",
  "message": "Human-readable description",
  "timestamp": "2026-07-28T15:00:00Z"
}
```

| HTTP Status | Error Code          | When Used                           |
|-------------|---------------------|-------------------------------------|
| 400         | VALIDATION_ERROR    | Invalid or missing input fields     |
| 401         | UNAUTHORIZED        | Missing or invalid auth token       |
| 403         | FORBIDDEN           | Authenticated but not authorised    |
| 404         | NOT_FOUND           | Resource does not exist             |
| 500         | INTERNAL_ERROR      | Unexpected server error             |
| 503         | SERVICE_UNAVAILABLE | Circuit open / dependency down      |

---

## 4. Security Rules
- All API keys and tokens are read from environment variables — never hardcoded in requests or code
- All endpoints enforce input validation via `InputValidator`
- All external API calls are made through `ExternalApiClient` (with retry + circuit breaker)
- HTTPS/TLS enforced in all non-local environments

---

## 5. Open Items
- OQ-001: Confluence will define actual domain entity names and business endpoints
- OQ-003: External APIs will add additional client-side contracts here
