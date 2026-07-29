# Requirements Specification

**Project:** GIthubCopilotCapstone  
**Phase:** Requirements  
**Source:** User instructions + `requirements/requirement.txt` (Confluence URL configured)  
**Status:** DRAFT — Awaiting open question resolutions (OQ-002 to OQ-005)

---

## 1. Requirement Source
| Source               | Reference                                         |
|----------------------|---------------------------------------------------|
| Confluence Page      | `https://subhasree.atlassian.net/wiki/spaces/~712020ff355f343c4d4b6b9b7cc6aa838aff7b/pages/14090241/Requirements` |
| User Instructions    | Direct input during project initiation session    |
| Analysis Document    | `project-scoping/analysis.md`                     |

---

## 2. Functional Requirements

### SDLC Pipeline

| ID     | Requirement                                                                                       | Priority | Acceptance Criteria                                                                                   |
|--------|---------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|
| FR-001 | The system shall implement an end-to-end SDLC pipeline with phases: Analysis, Requirements, Planning, Design, Development, Review, Testing, Deployment, Documentation. | Must Have | All 9 phases exist as directories with corresponding artifacts and agent prompt files.                |
| FR-002 | Each SDLC phase shall have a dedicated agent with defined skills and a system prompt.             | Must Have | 9 phase agent files exist under `agents/` each containing Role, Skills, System Prompt, Input, Output, and Completion Criteria. |
| FR-003 | A single Orchestrator Agent shall coordinate all phase agents, enforce phase gates, and log pipeline execution. | Must Have | `agents/orchestrator/orchestrator-agent.md` exists. `agents/orchestrator/pipeline-log.md` is updated at each phase transition. |
| FR-004 | The Orchestrator shall read the Confluence requirement URL from `requirements/requirement.txt`.   | Must Have | Orchestrator reads the file at startup and uses the configured URL.                                   |
| FR-005 | User confirmation must be obtained before each phase transition.                                  | Must Have | Pipeline pauses and prompts user before advancing to the next phase. No auto-advance without approval.|

### Pre-Commit Hooks

| ID     | Requirement                                                                                       | Priority | Acceptance Criteria                                                                                   |
|--------|---------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|
| FR-006 | A pre-commit hook shall scan all staged files and block the commit if any hardcoded API key, password, token, or secret is detected. | Must Have | Attempting to commit a file containing a hardcoded secret (e.g., `password=abc123`) is blocked with a clear error message. |
| FR-007 | A pre-commit hook shall validate that all required external connections (APIs, databases) are reachable before commit. | Must Have | Commit is blocked if a configured connection is unreachable. A skip flag shall be available for offline development. |
| FR-008 | Hook scripts shall be version-controlled under `.github/hooks/` and automatically installed for new developers. | Must Have | `setup.sh` or equivalent installs hooks on `git clone`. Hooks are active in CI/CD pipeline.          |

### Self-Healing Automation

| ID     | Requirement                                                                                       | Priority | Acceptance Criteria                                                                                   |
|--------|---------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|
| FR-009 | Every external API or service call shall implement retry logic with exponential backoff.          | Must Have | A failed external call is retried up to 3 times with delays of 1s, 2s, 4s before failing.            |
| FR-010 | The system shall implement a circuit breaker pattern for external dependencies.                   | Must Have | After 3 consecutive failures, the circuit opens and further calls return a fallback response immediately without attempting the call. |
| FR-011 | The system shall provide graceful degradation when an external dependency is unavailable.         | Must Have | Application continues operating in a degraded mode with a fallback response when circuit is open.     |
| FR-012 | The Orchestrator Agent shall detect phase agent failures and trigger self-healing retry.          | Must Have | Failed phase agent is retried up to 3 times. After 3 failures, pipeline is paused and user is notified. |

### CI/CD Pipeline

| ID     | Requirement                                                                                       | Priority | Acceptance Criteria                                                                                   |
|--------|---------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|
| FR-013 | A CI/CD pipeline shall be configured in GitHub Actions with stages: secret-scan, build, test, security-test, deploy. | Must Have | `.github/workflows/ci-cd.yml` exists and all stages execute on push to main branch.                  |
| FR-014 | The CI/CD pipeline shall fail and block deployment if secret scan detects hardcoded credentials. | Must Have | Push containing a hardcoded secret fails at the secret-scan stage.                                    |
| FR-015 | The CI/CD pipeline shall run all unit, integration, and security tests before deployment.        | Must Have | Deployment stage does not execute unless all prior test stages pass.                                  |

---

## 3. Non-Functional Requirements

### Security

| ID      | Requirement                                                                                      | Priority | Acceptance Criteria                                                                                   |
|---------|--------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|
| NFR-001 | No API keys, passwords, tokens, or connection strings shall appear in source code or configuration files. | Must Have | Secret scan hook and CI/CD scan return zero findings on the codebase.                                 |
| NFR-002 | All secrets shall be managed via environment variables or a secrets manager.                     | Must Have | All secret references in code use `System.getenv()` or equivalent. No literals.                      |
| NFR-003 | All external connections shall use encrypted transport (TLS/HTTPS).                              | Must Have | No plaintext HTTP connections to external APIs. TLS version ≥ 1.2.                                   |
| NFR-004 | Input validation shall be applied to all user-supplied or external data.                         | Must Have | Malformed inputs are rejected with appropriate error responses. No raw input reaches business logic.  |

### Reliability & Availability

| ID      | Requirement                                                                                      | Priority | Acceptance Criteria                                                                                   |
|---------|--------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|
| NFR-005 | The system shall recover automatically from transient external failures without manual intervention. | Must Have | Self-healing retry + circuit breaker restores operation within 30 seconds of transient failure.       |
| NFR-006 | The application shall provide health check endpoints for monitoring.                             | Should Have | `/health` endpoint returns 200 OK when system is healthy; 503 when degraded.                        |

### Maintainability

| ID      | Requirement                                                                                      | Priority | Acceptance Criteria                                                                                   |
|---------|--------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|
| NFR-007 | Code coverage shall be ≥ 80% as measured by automated tests.                                    | Must Have | Test report shows ≥ 80% line coverage.                                                                |
| NFR-008 | All public APIs and complex logic shall be documented with Javadoc comments.                     | Should Have | Javadoc generates without errors. All public methods have descriptions.                              |
| NFR-009 | Documentation shall be kept in sync with the codebase at every phase.                           | Must Have | Documentation Agent runs after Development and Deployment phases.                                     |

### Portability

| ID      | Requirement                                                                                      | Priority | Acceptance Criteria                                                                                   |
|---------|--------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|
| NFR-010 | The application shall be deployable to cloud, on-prem, or container environments.               | Should Have | Application runs with no code changes when environment variables are set for the target environment.  |

---

## 4. Constraints
1. Language: Java (version to be confirmed — see Open Questions).
2. Build tool: Maven or Gradle (to be confirmed).
3. Source control: GitHub (`SubhasriGit/MCPRepo`).
4. No hardcoded credentials under any circumstances.
5. All phase gates require user confirmation before advancement.

---

## 5. Requirements Traceability Matrix

| Req ID  | Source                        | Phase Agent           | Deliverable                          | Test ID (TBD) |
|---------|-------------------------------|----------------------|--------------------------------------|---------------|
| FR-001  | User instructions             | OrchestratorAgent    | `agents/` directory structure        | T-001         |
| FR-002  | User instructions             | OrchestratorAgent    | Agent `.md` files                    | T-002         |
| FR-003  | User instructions             | OrchestratorAgent    | `agents/orchestrator/`               | T-003         |
| FR-004  | User instructions             | OrchestratorAgent    | `requirements/requirement.txt`       | T-004         |
| FR-005  | User instructions             | OrchestratorAgent    | Pipeline gate logic                  | T-005         |
| FR-006  | User instructions             | DevelopmentAgent     | `.github/hooks/pre-commit-secrets`   | T-006         |
| FR-007  | User instructions             | DevelopmentAgent     | `.github/hooks/pre-commit-connect`   | T-007         |
| FR-008  | User instructions             | DevelopmentAgent     | Hook install scripts                 | T-008         |
| FR-009  | User instructions             | DevelopmentAgent     | `RetryWrapper.java`                  | T-009         |
| FR-010  | User instructions             | DevelopmentAgent     | `CircuitBreaker.java`                | T-010         |
| FR-011  | User instructions             | DevelopmentAgent     | Fallback response logic              | T-011         |
| FR-012  | User instructions             | OrchestratorAgent    | Orchestrator retry logic             | T-012         |
| FR-013  | User instructions             | DeploymentAgent      | `.github/workflows/ci-cd.yml`        | T-013         |
| FR-014  | User instructions             | DeploymentAgent      | CI/CD secret-scan stage              | T-014         |
| FR-015  | User instructions             | DeploymentAgent      | CI/CD test stage gate                | T-015         |
| NFR-001 | User instructions             | ReviewAgent          | Secret scan results                  | T-016         |
| NFR-002 | User instructions             | DevelopmentAgent     | Code review — no literals            | T-017         |
| NFR-003 | Security best practice        | DevelopmentAgent     | TLS connection config                | T-018         |
| NFR-004 | Security best practice        | DevelopmentAgent     | Input validation layer               | T-019         |
| NFR-005 | User instructions             | DevelopmentAgent     | Self-healing tests                   | T-020         |
| NFR-006 | Best practice                 | DevelopmentAgent     | Health endpoint                      | T-021         |
| NFR-007 | User instructions             | TestingAgent         | Test coverage report                 | T-022         |
| NFR-008 | Best practice                 | DevelopmentAgent     | Javadoc output                       | T-023         |
| NFR-009 | User instructions             | DocumentationAgent   | Docs in sync with code               | T-024         |
| NFR-010 | User instructions             | DeploymentAgent      | Environment-based config             | T-025         |

---

## 6. Open Questions
- [x] **OQ-001** — What is the Confluence page URL? *(Resolved: configured in `requirements/requirement.txt`)*
- [ ] **OQ-002** — Is the build tool Maven or Gradle? *(Blocks: Development phase setup)*
- [ ] **OQ-003** — What external APIs or databases will the project connect to? *(Blocks: hook design, self-healing design)*
- [ ] **OQ-004** — What is the Java version? *(Blocks: build config)*
- [ ] **OQ-005** — What is the target deployment environment? *(Blocks: Deployment phase)*

---

## 7. Next Phase
➡️ **Planning** — Build Work Breakdown Structure and project plan based on these requirements.
