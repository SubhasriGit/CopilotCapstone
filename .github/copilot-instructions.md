# Copilot Instructions — OfficeCheck Capstone

## Build & Test Commands

```bash
# Full build (skips tests)
mvn clean install -DskipTests

# Run all tests + JaCoCo coverage gate (≥ 80% line coverage required)
mvn verify

# Run a single test class
mvn -pl . -Dtest=AppControllerTest test

# Run a single test method
mvn -pl . -Dtest=AppIntegrationTest#healthEndpointReturnsUp test

# Run app locally (requires .env vars exported first)
mvn clean package -DskipTests
java -jar target/github-copilot-capstone-1.0.0-SNAPSHOT.jar
```

> **Windows note:** Maven is not on PATH. Use IntelliJ-bundled Maven and set `$env:JAVA_HOME` before running:
> ```powershell
> $env:JAVA_HOME = "C:\Users\<you>\.jdks\ms-17.0.16"
> $mvn = "C:\Program Files\JetBrains\IntelliJ IDEA <ver>\plugins\maven\lib\maven3\bin\mvn.cmd"
> & $mvn verify
> ```

## Architecture

The app is a Spring Boot 3.2.5 REST API (Java 17, H2 in-memory DB) with a self-healing layer and an SDLC orchestration scaffold alongside it.

### Two distinct concerns in this repo

1. **Java application** (`src/`) — the deployable Spring Boot service
2. **SDLC pipeline scaffold** (`agents/`, `prompts/`, `skills/`, `requirements/`, `design/`, etc.) — agent instructions and artifacts for running the 9-phase Copilot-orchestrated SDLC workflow

These two concerns coexist but are independent. Changes to agent markdown files do not affect the Java build.

### Java application layers

```
ConfigLoader          ← all config from env vars only (never hardcoded)
     │
ConnectionValidator   ← startup health checks for external URLs
     │
ExternalApiClient     ← WebClient + RetryWrapper + CircuitBreaker
     │
AppService            ← business logic (CRUD over AppEntity via AppRepository)
     │
AppController         ← /api/v1/entities (CRUD, UUID-validated, input-sanitised)
HealthController      ← /health (reports connection + circuit breaker state)
WelcomeController     ← GET / (info/links)
GlobalExceptionHandler← catches NoHandlerFoundException → structured JSON 404
```

**Resilience chain:** every external call in `ExternalApiClient` passes through `RetryWrapper` (exponential backoff, configurable via `RETRY_MAX_ATTEMPTS` / `RETRY_BASE_DELAY_MS`) then `CircuitBreaker` (CLOSED → OPEN → HALF_OPEN, configurable via `CB_FAILURE_THRESHOLD` / `CB_RESET_TIMEOUT_MS`). On open circuit, `FallbackHandler` returns a safe default instead of propagating the error.

### SDLC pipeline

The orchestrator (run via `run-orchestrator.ps1` or `bash .github/hooks/agent-pre-run-hook.sh`) executes 9 phases with HITL gates between them. Phase log is written to `agents/orchestrator/pipeline-log.md`. Flags:
- `OFFLINE_MODE=true` — skips connection validation (use when external services are unreachable)
- `SKIP_SECRET_CHECK=true` — skips the secret scan step
- `INTERACTIVE_MODE=false` — auto-approves all HITL gates (CI/CD pipeline mode)

## Key Conventions

### All configuration via environment variables
`ConfigLoader` is the single entry point for all config. Never read `System.getenv()` directly in any other class — always inject `ConfigLoader`. Use `getRequired()` for mandatory keys, `getOrDefault()` for optional ones with safe defaults.

### HTTPS enforcement at construction time
`ExternalApiClient` throws `IllegalStateException` in its constructor if `APP_ENV != "local"` and `EXTERNAL_API_URL` starts with `http://`. The safe default fallback URL is `https://api.example.com`. This guard runs before the Spring context fully starts, so a wrong URL with `APP_ENV=production` will crash startup.

### 404 handling — no Whitelabel page
`server.error.whitelabel.enabled=false`, `spring.mvc.throw-exception-if-no-handler-found=true`, and `spring.web.resources.add-mappings=false` are all set. Unknown paths raise `NoHandlerFoundException`, caught by `GlobalExceptionHandler`, which returns a JSON body with `status`, `error`, `message`, `path`, and a `links` map. Do **not** add a `@RestController` mapped to `/error` — it conflicts with Spring Boot's `BasicErrorController`.

### Input validation pattern
All controller paths call `InputValidator` before any business logic: `requireValidUuid` for path IDs, `requireNonBlank` + `requireMaxLength` for body fields, then `sanitise()` to strip dangerous characters. Validation errors throw `IllegalArgumentException`, caught by `AppController`'s own `@ExceptionHandler`.

### Test structure
| Package | What it tests |
|---|---|
| `unit/` | Service, controller, config, input validator in isolation (Mockito) |
| `resilience/` | RetryWrapper, CircuitBreaker, FallbackHandler in isolation |
| `security/` | ConnectionValidator, InputValidator edge cases |
| `client/` | `ExternalApiClient` using embedded `com.sun.net.httpserver.HttpServer` (no WireMock) |
| `integration/` | Full Spring context with H2 + `@MockBean ConnectionValidator` (prevents real network calls in CI) |

**Coverage gate:** `mvn verify` enforces ≥ 80% line coverage via JaCoCo. Run `mvn verify` — never `mvn test jacoco:report jacoco:check` (standalone `jacoco:check` fails with `PluginParameterException: rules missing`).

### Server port resolution
`server.port=${PORT:${APP_PORT:8080}}` — Render injects `PORT`; local dev uses `APP_PORT` from `.env`; default is 8080.

### Pre-commit hooks
`setup.sh` installs two Git hooks:
- `pre-commit-secrets` — blocks commits containing hardcoded credential patterns
- `pre-commit-connect` — validates external connections before committing

Set `OFFLINE_MODE=true` in `.env` to bypass the connection hook for offline work.

### CI/CD pipeline (`.github/workflows/ci-cd.yml`)
Six jobs: `build → test+coverage → security` (parallel), then `deploy → smoke_test → rollback`. The OWASP dependency check has `continue-on-error: true` and `timeout-minutes: 20`; it caches `~/.m2/.owasp/dependency-check` between runs. Deployment requires three GitHub secrets: `RENDER_DEPLOY_HOOK_URL`, `RENDER_API_KEY`, `RENDER_SERVICE_ID`.

### Dockerfile
Uses a two-stage build (Maven 3.9 + Eclipse Temurin 20 builder → Amazon Corretto 20 runtime). Note: the Dockerfile still references Java 20 images while `pom.xml` targets Java 17 — the build works because Java 20 can compile Java 17 source, but align these when updating the base image.

## Environment Variables Reference

| Variable | Required | Default | Notes |
|---|---|---|---|
| `APP_ENV` | No | `local` | Set to `production` in CI/Render; enables HTTPS enforcement |
| `APP_PORT` | No | `8080` | Overridden by `PORT` on Render |
| `EXTERNAL_API_URL` | No | `https://api.example.com` | Must be HTTPS when `APP_ENV != local` |
| `EXTERNAL_API_KEY` | No | `""` | Sent as `X-API-Key` header |
| `DB_URL` | No | H2 in-memory | Set for PostgreSQL in production |
| `DB_USERNAME` / `DB_PASSWORD` | No | `sa` / `""` | H2 defaults for local dev |
| `RETRY_MAX_ATTEMPTS` | No | `3` | RetryWrapper attempts |
| `RETRY_BASE_DELAY_MS` | No | `1000` | Base delay for exponential backoff |
| `CB_FAILURE_THRESHOLD` | No | `3` | Failures before circuit opens |
| `CB_RESET_TIMEOUT_MS` | No | `30000` | OPEN → HALF_OPEN timeout |
| `OFFLINE_MODE` | No | `false` | Skip connection checks in hooks |

## MCP Servers

MCP configuration is in `MCP/`. Four servers are configured: `atlassian` (Confluence + Jira via `uvx mcp-atlassian`), `github`, `gitlab`, and `playwright` (all via `npx`). Config file location: `%APPDATA%\GitHub Copilot\mcp.json` (Windows) or `~/.config/github-copilot/mcp.json`. See `MCP/README.md` for full setup instructions and required env vars.
