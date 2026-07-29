# Component Design

**Project:** GIthubCopilotCapstone  
**Document:** Component Design  
**Input:** `design/architecture.md`

---

## 1. Component Map

```
AppController          → delegates to → AppService
AppService             → uses         → AppRepository, ExternalApiClient
AppRepository          → accesses     → Database
ExternalApiClient      → wrapped by   → RetryWrapper → CircuitBreaker → FallbackHandler
ConfigLoader           → reads        → Environment Variables
InputValidator         → used by      → AppController
HealthController       → exposes      → /health endpoint
ConnectionValidator    → used by      → Hook + Startup
```

---

## 2. Component Specifications

### 2.1 AppController
| Attribute     | Detail                                                     |
|---------------|------------------------------------------------------------|
| Package       | `com.capstone.api`                                         |
| Responsibility| Accept HTTP requests, validate input, return responses     |
| Dependencies  | `AppService`, `InputValidator`                             |
| Methods       | `handleRequest()`, `handleError()`                         |
| Rules         | Must call `InputValidator` before passing data to service  |

---

### 2.2 AppService
| Attribute     | Detail                                                     |
|---------------|------------------------------------------------------------|
| Package       | `com.capstone.service`                                     |
| Responsibility| Business logic, orchestrate data and external calls        |
| Dependencies  | `AppRepository`, `ExternalApiClient`                       |
| Methods       | Business-specific methods (TBD from Confluence)            |
| Rules         | Must not contain data access SQL. Must not call external APIs directly — use `ExternalApiClient`. |

---

### 2.3 AppRepository
| Attribute     | Detail                                                     |
|---------------|------------------------------------------------------------|
| Package       | `com.capstone.repository`                                  |
| Responsibility| CRUD operations against database                           |
| Dependencies  | Database (config from `ConfigLoader`)                      |
| Methods       | `findById()`, `findAll()`, `save()`, `delete()`            |
| Rules         | Connection string must come from `ConfigLoader` (env vars). |

---

### 2.4 ExternalApiClient
| Attribute     | Detail                                                     |
|---------------|------------------------------------------------------------|
| Package       | `com.capstone.client`                                      |
| Responsibility| All HTTP calls to external APIs                            |
| Dependencies  | `RetryWrapper`, `CircuitBreaker`, `ConfigLoader`           |
| Methods       | `get()`, `post()`, `put()`, `delete()`                     |
| Rules         | Every call MUST go through `RetryWrapper`. API key from env var only. |

---

### 2.5 RetryWrapper
| Attribute     | Detail                                                         |
|---------------|----------------------------------------------------------------|
| Package       | `com.capstone.resilience`                                      |
| Responsibility| Wrap any callable with retry + exponential backoff             |
| Dependencies  | `ConfigLoader` (for retry config)                              |
| Methods       | `execute(Callable task, int maxAttempts, long baseDelayMs)`    |
| Behaviour     | Retries up to `maxAttempts` with delay doubling each attempt   |
| Rules         | Must log each retry attempt. Must throw after max attempts.    |

---

### 2.6 CircuitBreaker
| Attribute     | Detail                                                         |
|---------------|----------------------------------------------------------------|
| Package       | `com.capstone.resilience`                                      |
| Responsibility| Track failure counts; open circuit to stop calls on threshold  |
| Dependencies  | `ConfigLoader` (failure threshold)                             |
| States        | CLOSED (normal), OPEN (blocking), HALF-OPEN (testing recovery) |
| Methods       | `call(Callable task)`, `getState()`, `reset()`                 |
| Rules         | When OPEN, return fallback immediately without calling target.  |

---

### 2.7 FallbackHandler
| Attribute     | Detail                                                         |
|---------------|----------------------------------------------------------------|
| Package       | `com.capstone.resilience`                                      |
| Responsibility| Return safe default responses when circuit is open             |
| Dependencies  | None                                                           |
| Methods       | `getFallbackResponse(String operationName)`                    |
| Rules         | Must log every fallback invocation. Response must not expose internal errors. |

---

### 2.8 InputValidator
| Attribute     | Detail                                                         |
|---------------|----------------------------------------------------------------|
| Package       | `com.capstone.security`                                        |
| Responsibility| Validate and sanitise all incoming data                        |
| Dependencies  | None                                                           |
| Methods       | `validate(Object input)`, `sanitise(String input)`             |
| Rules         | Reject null, empty, or malformed inputs. Strip dangerous characters. |

---

### 2.9 ConfigLoader
| Attribute     | Detail                                                         |
|---------------|----------------------------------------------------------------|
| Package       | `com.capstone.config`                                          |
| Responsibility| Load all configuration from environment variables              |
| Dependencies  | None                                                           |
| Methods       | `get(String key)`, `getRequired(String key)`                   |
| Rules         | `getRequired()` throws `IllegalStateException` if env var is missing. No defaults for secrets. |

---

### 2.10 ConnectionValidator
| Attribute     | Detail                                                         |
|---------------|----------------------------------------------------------------|
| Package       | `com.capstone.security`                                        |
| Responsibility| Verify all configured connections are reachable                |
| Dependencies  | `ConfigLoader`                                                 |
| Methods       | `validateAll()`, `validateConnection(String name, String url)` |
| Rules         | Called at application startup and by pre-commit hook. Fails fast if critical connection is down. |

---

### 2.11 HealthController
| Attribute     | Detail                                                         |
|---------------|----------------------------------------------------------------|
| Package       | `com.capstone.health`                                          |
| Responsibility| Expose `/health` endpoint for monitoring                       |
| Dependencies  | `ConnectionValidator`, `CircuitBreaker`                        |
| Methods       | `health()` → HTTP 200 (healthy) or 503 (degraded)              |
| Rules         | Must reflect real system state. Never hardcode a healthy response. |

---

## 3. Component Dependency Graph

```
HealthController ──────────────────► ConnectionValidator
                                             │
AppController ──► InputValidator             │
      │                                      ▼
      └──────────► AppService ─────► ExternalApiClient
                       │                     │
                       │              RetryWrapper
                       │                     │
                       ▼              CircuitBreaker
                 AppRepository               │
                       │              FallbackHandler
                       ▼
                   Database
                       
All components ──► ConfigLoader (reads env vars)
```
