# Security Design

**Project:** GIthubCopilotCapstone  
**Document:** Security Design  
**References:** NFR-001 to NFR-004, FR-006, FR-007

---

## 1. Security Principles

| Principle                  | Implementation                                              |
|----------------------------|-------------------------------------------------------------|
| No hardcoded secrets        | All secrets via `System.getenv()` — enforced by pre-commit hook |
| Fail fast on missing config | `ConfigLoader.getRequired()` throws on missing env var      |
| Least privilege             | Each component only accesses what it needs                  |
| Input validation            | All external input sanitised before business logic          |
| Encrypted transport         | TLS 1.2+ enforced for all external connections              |
| Secret scanning             | Pre-commit hook + CI/CD scan on every push                  |

---

## 2. Secret Management

### 2.1 Rules
- **NEVER** hardcode credentials, API keys, passwords, tokens, or connection strings anywhere in source code, config files, or documentation.
- All secrets are loaded at runtime via `ConfigLoader.getRequired("ENV_VAR_NAME")`.
- If a required secret is missing at startup, the application must **fail fast** with a clear error message.
- Secrets must never appear in log output — mask with `***`.

### 2.2 Secret Loading Pattern
```java
// CORRECT — read from environment
String apiKey = ConfigLoader.getRequired("EXTERNAL_API_KEY");

// WRONG — never do this
String apiKey = "sk-abc123hardcoded";
```

### 2.3 Required Environment Variables
| Variable            | Purpose                           | Required |
|---------------------|-----------------------------------|----------|
| `DB_URL`            | Database connection URL           | Yes      |
| `DB_USERNAME`       | Database username                 | Yes      |
| `DB_PASSWORD`       | Database password                 | Yes      |
| `EXTERNAL_API_URL`  | External API base URL             | Yes      |
| `EXTERNAL_API_KEY`  | External API authentication key   | Yes      |
| `APP_PORT`          | Application port                  | No (default 8080) |

---

## 3. Input Validation Design

All user-supplied and externally-received data must pass through `InputValidator` before reaching business logic.

### 3.1 Validation Rules
| Input Type     | Rule                                                           |
|----------------|----------------------------------------------------------------|
| String fields  | Non-null, non-empty, max length enforced, no dangerous chars   |
| IDs            | Must match UUID pattern: `[0-9a-f]{8}-...-[0-9a-f]{12}`      |
| Enum values    | Must be one of the allowed enum constants                      |
| Numeric fields | Must be within defined min/max bounds                          |
| JSON payloads  | Schema-validated before deserialization                        |

### 3.2 Dangerous Input Patterns (Reject)
- SQL injection fragments: `'; DROP TABLE`, `OR 1=1`, etc.
- Script injection: `<script>`, `javascript:`, `onerror=`
- Path traversal: `../`, `..\`
- Null bytes: `\0`

---

## 4. Transport Security

| Connection Type        | Requirement                       |
|------------------------|-----------------------------------|
| External API calls     | HTTPS only — TLS 1.2 minimum      |
| Database connections   | TLS if supported by DB provider   |
| Local development      | HTTP permitted; TLS required in CI/CD and production |

### 4.1 Enforcement
`ExternalApiClient` must reject any URL that starts with `http://` in non-local environments. Read environment name from `APP_ENV` variable (`local`, `staging`, `production`).

---

## 5. Logging Security

| Rule                                         | Implementation                                    |
|----------------------------------------------|---------------------------------------------------|
| Never log secrets or credentials              | Mask with `***` in all log statements             |
| Never log raw user input                      | Log sanitised/truncated version only              |
| Never log full stack traces in production     | Log error code + message only in production mode  |
| Correlation IDs in all log entries            | Add `requestId` to every log line                 |

---

## 6. Secret Scanning Patterns (Used by Hook + CI)

The secret detection hook scans staged files for these patterns and blocks commits:

```
Patterns to detect:
  password\s*=\s*["'][^"']+["']
  api[_-]?key\s*=\s*["'][^"']+["']
  secret\s*=\s*["'][^"']+["']
  token\s*=\s*["'][^"']+["']
  [A-Za-z0-9+/]{40,}                  ← Base64 encoded secrets
  [A-Z0-9]{20,}                        ← AWS-style access keys
  ghp_[A-Za-z0-9]{36}                  ← GitHub personal access tokens
  sk-[A-Za-z0-9]{48}                   ← OpenAI API keys
```

---

## 7. Security Review Checklist (for ReviewAgent)

- [ ] Zero hardcoded secrets in all source files
- [ ] All env vars loaded via `ConfigLoader.getRequired()`
- [ ] `InputValidator` called at every controller entry point
- [ ] No `http://` external calls in non-local environments
- [ ] No secrets in log statements
- [ ] Secret scanning patterns cover all common secret formats
- [ ] `ConfigLoader` fails fast on missing required env vars
