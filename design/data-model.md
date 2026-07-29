# Data Model Design

**Project:** GIthubCopilotCapstone  
**Document:** Data Model  
**Note:** Specific entities will be updated once Confluence requirements (OQ-001) are available.

---

## 1. Core Domain Entities

### 1.1 AppEntity (Placeholder — update from Confluence)
```
AppEntity
├── id          : String (UUID)
├── name        : String
├── status      : Enum (ACTIVE, INACTIVE)
├── createdAt   : LocalDateTime
└── updatedAt   : LocalDateTime
```

### 1.2 PipelinePhase
```
PipelinePhase
├── id          : String (UUID)
├── phaseName   : Enum (ANALYSIS, REQUIREMENTS, PLANNING, DESIGN, 
│                       DEVELOPMENT, REVIEW, TESTING, DEPLOYMENT, DOCUMENTATION)
├── status      : Enum (PENDING, IN_PROGRESS, COMPLETE, BLOCKED)
├── agentName   : String
├── startedAt   : LocalDateTime
├── completedAt : LocalDateTime
└── notes       : String
```

### 1.3 PipelineLog
```
PipelineLog
├── id           : String (UUID)
├── phaseId      : String (FK → PipelinePhase.id)
├── timestamp    : LocalDateTime
├── eventType    : Enum (PHASE_START, PHASE_COMPLETE, PHASE_BLOCKED, GATE_APPROVED, RETRY)
├── message      : String
└── performedBy  : String (agent name or "USER")
```

### 1.4 ConnectionConfig
```
ConnectionConfig
├── name         : String (unique identifier)
├── url          : String (read from env var — never stored as literal)
├── type         : Enum (DATABASE, REST_API, MESSAGE_QUEUE)
└── isRequired   : Boolean
```

---

## 2. Entity Relationship Diagram

```
PipelinePhase ──── 1:N ──── PipelineLog
      │
      └── agentName references agents/ directory agent definitions

AppEntity (domain-specific — to be expanded from Confluence)
```

---

## 3. Data Storage Strategy

| Data Type           | Storage                             | Notes                                    |
|---------------------|-------------------------------------|------------------------------------------|
| Domain entities     | Database [OQ-003 — type TBD]        | Connection via env var `$DB_URL`          |
| Pipeline phase logs | File: `agents/orchestrator/pipeline-log.md` | For SDLC tracking                  |
| Configuration       | Environment variables only          | Never persisted to database or file      |
| Secrets             | Secrets manager / env vars          | Never in database, code, or config files |

---

## 4. Database Schema (Placeholder — update from Confluence)

```sql
-- AppEntity table (name and fields TBD from Confluence)
CREATE TABLE app_entity (
    id         VARCHAR(36)  PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    status     VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- PipelinePhase table
CREATE TABLE pipeline_phase (
    id           VARCHAR(36)  PRIMARY KEY,
    phase_name   VARCHAR(50)  NOT NULL,
    status       VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    agent_name   VARCHAR(100) NOT NULL,
    started_at   TIMESTAMP,
    completed_at TIMESTAMP,
    notes        TEXT
);

-- PipelineLog table
CREATE TABLE pipeline_log (
    id           VARCHAR(36)  PRIMARY KEY,
    phase_id     VARCHAR(36)  NOT NULL REFERENCES pipeline_phase(id),
    timestamp    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    event_type   VARCHAR(30)  NOT NULL,
    message      TEXT,
    performed_by VARCHAR(100)
);
```

> ⚠️ Database connection credentials are NEVER stored in schema files.  
> Use `$DB_URL`, `$DB_USERNAME`, `$DB_PASSWORD` environment variables.

---

## 5. Open Items
- OQ-001: Confluence requirements will define the actual domain entities
- OQ-003: External API / database type will finalise storage strategy
