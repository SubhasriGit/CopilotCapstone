# Hooks & Self-Healing Design

**Project:** GIthubCopilotCapstone  
**Document:** Hooks and Self-Healing Design  
**References:** FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-012

---

## 1. Pre-Commit Hooks Overview

Two hooks run automatically before every `git commit`:

| Hook                    | Script                              | Purpose                                           |
|-------------------------|-------------------------------------|---------------------------------------------------|
| Secret Detection Hook   | `.github/hooks/pre-commit-secrets`  | Block commit if hardcoded secret detected         |
| Connection Validation Hook | `.github/hooks/pre-commit-connect` | Block commit if a required connection is down    |

Both hooks are installed via `setup.sh` into `.git/hooks/` on developer machines and run as a pre-job step in CI/CD.

---

## 2. Secret Detection Hook Design

### 2.1 Flow
```
git commit triggered
       │
       ▼
pre-commit-secrets runs
       │
       ▼
Get list of staged files (git diff --cached --name-only)
       │
       ▼
For each staged file:
  Scan file contents against secret patterns (see security-design.md §6)
       │
       ├─ Pattern found? → BLOCK COMMIT
       │                   Print: "ERROR: Hardcoded secret detected in <file>:<line>"
       │                   Print: "Remove the secret and use environment variables instead."
       │                   Exit code 1
       │
       └─ No pattern found → Continue to next file
       
All files clean → Allow commit (exit code 0)
```

### 2.2 Script Location
- Source: `.github/hooks/pre-commit-secrets`
- Installed to: `.git/hooks/pre-commit` (by `setup.sh`)
- CI/CD: Runs as first stage in GitHub Actions workflow

### 2.3 Skip Flag (Emergency Use Only)
```bash
# Skip for this commit only — must be approved by team lead
SKIP_SECRET_CHECK=true git commit -m "message"
```
> ⚠️ Skipping must be logged and justified. CI/CD secret scan still runs and cannot be skipped.

---

## 3. Connection Validation Hook Design

### 3.1 Flow
```
git commit triggered (after secret check passes)
       │
       ▼
pre-commit-connect runs
       │
       ▼
Read connection list from environment variables:
  - DB_URL (if set)
  - EXTERNAL_API_URL (if set)
       │
       ▼
For each configured connection:
  Attempt TCP/HTTP ping with 5-second timeout
       │
       ├─ Unreachable? → WARN (if non-critical) or BLOCK (if critical)
       │                 Print: "WARNING: Cannot reach <connection-name> at <url>"
       │
       └─ Reachable? → Continue
       
All critical connections reachable → Allow commit (exit code 0)
Offline mode (OFFLINE_MODE=true) → Skip connection check entirely
```

### 3.2 Critical vs Non-Critical Connections
| Connection        | Criticality | Behaviour on failure  |
|-------------------|-------------|----------------------|
| Database          | Critical    | Block commit         |
| External API      | Non-critical| Warn, allow commit   |

---

## 4. Hook Install Script Design

### 4.1 `setup.sh`
```
Run setup.sh after git clone:
  1. Copy .github/hooks/pre-commit-secrets to .git/hooks/pre-commit-secrets
  2. Copy .github/hooks/pre-commit-connect to .git/hooks/pre-commit-connect
  3. Create .git/hooks/pre-commit that calls both hooks in order
  4. chmod +x all hook files
  5. Print: "✅ Pre-commit hooks installed successfully"
```

---

## 5. Self-Healing Design

### 5.1 RetryWrapper

**Pattern:** Retry with Exponential Backoff

```
Call attempt 1
  │
  ├─ Success → Return result
  └─ Failure → Wait 1s → Call attempt 2
                  │
                  ├─ Success → Return result
                  └─ Failure → Wait 2s → Call attempt 3
                                  │
                                  ├─ Success → Return result
                                  └─ Failure → Throw RetryExhaustedException
```

**Config (from env vars):**
- `RETRY_MAX_ATTEMPTS` (default: 3)
- `RETRY_BASE_DELAY_MS` (default: 1000)
- Delay formula: `baseDelay * 2^(attemptNumber - 1)`

---

### 5.2 CircuitBreaker

**States:**
```
CLOSED ──(failures >= threshold)──► OPEN ──(reset timeout elapsed)──► HALF-OPEN
  ▲                                                                        │
  └────────────────(test call succeeds)───────────────────────────────────┘
                   (test call fails → back to OPEN)
```

**Config (from env vars):**
- `CB_FAILURE_THRESHOLD` (default: 3) — failures before opening
- `CB_RESET_TIMEOUT_MS` (default: 30000) — wait before half-open test

**Behaviour:**
| State      | Action on call                              |
|------------|---------------------------------------------|
| CLOSED     | Execute call normally                       |
| OPEN       | Return fallback immediately (no call made)  |
| HALF-OPEN  | Execute one test call; close on success     |

---

### 5.3 FallbackHandler

Provides safe default responses when circuit is OPEN:

| Operation            | Fallback Response                                |
|----------------------|--------------------------------------------------|
| External API GET     | Return cached last-known-good response (if any) |
| External API POST    | Queue for later retry; return 202 Accepted       |
| Database read        | Return empty list with `source: "fallback"` flag |
| Database write       | Queue write; return 202 Accepted                 |

---

### 5.4 Orchestrator Self-Healing (Phase Agent Failures)

```
Phase agent executes
       │
       ├─ Success → Log COMPLETE → Advance pipeline
       └─ Failure → Attempt 1 retry (wait 5s)
                        │
                        ├─ Success → Log RECOVERED → Advance pipeline
                        └─ Failure → Attempt 2 retry (wait 10s)
                                         │
                                         ├─ Success → Log RECOVERED
                                         └─ Failure → Attempt 3 retry (wait 20s)
                                                          │
                                                          ├─ Success → Log RECOVERED
                                                          └─ Failure → Log BLOCKED
                                                                        Pause pipeline
                                                                        Notify user
```

---

## 6. Self-Healing Test Requirements

| Component        | Test Scenario                                              | Expected Outcome                         |
|------------------|------------------------------------------------------------|------------------------------------------|
| RetryWrapper     | Simulate 2 failures then success                           | Returns result on 3rd attempt            |
| RetryWrapper     | Simulate 3 consecutive failures                            | Throws `RetryExhaustedException`         |
| CircuitBreaker   | Trigger 3 failures                                         | Circuit moves to OPEN                    |
| CircuitBreaker   | Call while OPEN                                            | Returns fallback immediately, no call    |
| CircuitBreaker   | Wait reset timeout, next call succeeds                     | Circuit moves to CLOSED                  |
| FallbackHandler  | Call with OPEN circuit                                     | Returns safe fallback response           |
| Secret Hook      | Stage file with `password="secret123"`                     | Commit blocked                           |
| Connection Hook  | Set DB_URL to unreachable host                             | Commit blocked with warning message      |
