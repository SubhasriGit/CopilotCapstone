# System Architecture

**Project:** GIthubCopilotCapstone  
**Document:** Architecture Overview  
**Input:** `requirements/requirements-spec.md`, `planning/project-plan.md`

---

## 1. Architectural Style
**Layered Architecture (N-Tier)** with a cross-cutting self-healing and security layer.

```
┌─────────────────────────────────────────────────────────┐
│                    Client / Consumer                    │
└────────────────────────┬────────────────────────────────┘
                         │ HTTP / REST
┌────────────────────────▼────────────────────────────────┐
│                   API / Controller Layer                │
│           (Input Validation, Request Routing)           │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                   Service / Business Layer              │
│         (Business Logic, Orchestration, Rules)          │
└──────────┬─────────────────────────────────┬────────────┘
           │                                 │
┌──────────▼──────────┐          ┌───────────▼────────────┐
│  Data Access Layer  │          │  External API Client   │
│  (Repository / DAO) │          │  (wrapped in Self-     │
│                     │          │   Healing Utilities)   │
└──────────┬──────────┘          └───────────┬────────────┘
           │                                 │
┌──────────▼──────────┐          ┌───────────▼────────────┐
│   Database / Store  │          │  External APIs / DBs   │
│   [OQ-003 TBD]      │          │  [OQ-003 TBD]          │
└─────────────────────┘          └────────────────────────┘

─────────── Cross-Cutting Concerns ───────────
┌─────────────────────────────────────────────┐
│  Security Layer  │  Self-Healing Layer       │
│  - Secret Mgmt   │  - RetryWrapper           │
│  - Input Valid.  │  - CircuitBreaker         │
│  - TLS Enforce   │  - FallbackHandler        │
└─────────────────────────────────────────────┘

─────────── DevOps / Pipeline ────────────────
┌─────────────────────────────────────────────┐
│  Pre-Commit Hooks  │  CI/CD (GitHub Actions) │
│  - SecretScan      │  - Secret Scan Stage    │
│  - ConnValidation  │  - Build Stage          │
│                    │  - Test Stage           │
│                    │  - Deploy Stage         │
└─────────────────────────────────────────────┘
```

---

## 2. Layer Responsibilities

| Layer                  | Responsibility                                                      |
|------------------------|---------------------------------------------------------------------|
| API / Controller       | Accept HTTP requests, validate input, delegate to Service layer     |
| Service / Business     | Execute business rules, orchestrate data and external calls         |
| Data Access            | CRUD operations against the data store                              |
| External API Client    | All calls to external systems, wrapped in self-healing utilities    |
| Security Layer         | Secret management, input sanitisation, TLS enforcement              |
| Self-Healing Layer     | Retry, circuit breaker, fallback for every external dependency      |
| Pre-Commit Hooks       | Block commits with secrets or broken connections                    |
| CI/CD Pipeline         | Automate build, test, scan, deploy on every push                    |

---

## 3. Key Design Decisions

| Decision                          | Choice                        | Rationale                                          |
|-----------------------------------|-------------------------------|---------------------------------------------------|
| Architecture style                | Layered (N-Tier)              | Clear separation of concerns, easy to test        |
| Secret management                 | Environment variables         | No secrets in code or config files                |
| External call resilience          | Retry + Circuit Breaker       | Self-healing without manual intervention          |
| Connection validation             | Pre-commit hook + startup     | Fail fast before code reaches repository          |
| API style                         | REST / HTTP                   | Standard, widely understood [OQ-003 may change]  |
| Build tool                        | TBD [OQ-002]                  | Maven or Gradle pending confirmation              |
| Deployment target                 | TBD [OQ-005]                  | Cloud / on-prem / container pending confirmation  |

---

## 4. Package Structure

```
src/
├── main/
│   └── java/
│       └── com/capstone/
│           ├── api/           ← Controllers / REST endpoints
│           ├── service/       ← Business logic
│           ├── repository/    ← Data access (DAO/Repository)
│           ├── model/         ← Domain models / entities
│           ├── client/        ← External API clients
│           ├── resilience/    ← RetryWrapper, CircuitBreaker, FallbackHandler
│           ├── security/      ← Input validation, config security
│           ├── health/        ← Health check endpoint
│           └── config/        ← App configuration (reads env vars only)
└── test/
    └── java/
        └── com/capstone/
            ├── unit/
            ├── integration/
            ├── security/
            └── resilience/
```

---

## 5. Environment Configuration

All runtime configuration is supplied via environment variables. No hardcoded values.

| Environment Variable | Purpose                              |
|----------------------|--------------------------------------|
| `APP_PORT`           | Port the application listens on      |
| `DB_URL`             | Database connection URL              |
| `DB_USERNAME`        | Database username                    |
| `DB_PASSWORD`        | Database password                    |
| `EXTERNAL_API_URL`   | Base URL for external API            |
| `EXTERNAL_API_KEY`   | API key for external service         |
| `RETRY_MAX_ATTEMPTS` | Max retry attempts for self-healing  |
| `RETRY_BASE_DELAY_MS`| Base delay (ms) for exponential backoff |
| `CB_FAILURE_THRESHOLD`| Circuit breaker failure threshold   |

> ⚠️ **Never hardcode any of these values. Always use `System.getenv("VAR_NAME")`.**

---

## 6. Open Items
- OQ-002: Build tool (Maven/Gradle) affects package layout
- OQ-003: External APIs/databases affect client and data access design
- OQ-004: Java version affects feature usage
- OQ-005: Deployment target affects containerisation/config approach
