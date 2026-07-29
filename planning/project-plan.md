# Project Plan

**Project:** GIthubCopilotCapstone  
**Phase:** Planning  
**Input:** `requirements/requirements-spec.md`, `project-scoping/analysis.md`  
**Status:** DRAFT — Awaiting open question resolutions (OQ-002 to OQ-005)

---

## 1. Work Breakdown Structure (WBS)

```
GIthubCopilotCapstone
├── 1.0  Project Setup
│   ├── 1.1  Initialise repository structure
│   ├── 1.2  Configure build tool (Maven/Gradle) [OQ-002]
│   ├── 1.3  Set Java version [OQ-004]
│   └── 1.4  Configure .gitignore and base project files
│
├── 2.0  Pre-Commit Hooks
│   ├── 2.1  Design secret detection hook  [FR-006]
│   ├── 2.2  Implement secret detection hook
│   ├── 2.3  Design connection validation hook  [FR-007]
│   ├── 2.4  Implement connection validation hook
│   ├── 2.5  Write hook install script  [FR-008]
│   └── 2.6  Test hooks
│
├── 3.0  Self-Healing Utilities
│   ├── 3.1  Design retry with exponential backoff  [FR-009]
│   ├── 3.2  Implement RetryWrapper
│   ├── 3.3  Design circuit breaker  [FR-010]
│   ├── 3.4  Implement CircuitBreaker
│   ├── 3.5  Design fallback / graceful degradation  [FR-011]
│   └── 3.6  Implement fallback handlers
│
├── 4.0  Core Application
│   ├── 4.1  Design system architecture  [FR-001]
│   ├── 4.2  Design components and interfaces
│   ├── 4.3  Design data models
│   ├── 4.4  Design API contracts  [OQ-003]
│   ├── 4.5  Implement components
│   ├── 4.6  Implement data access layer
│   ├── 4.7  Implement API / service layer
│   └── 4.8  Implement health check endpoint  [NFR-006]
│
├── 5.0  Security
│   ├── 5.1  Design secret management strategy  [NFR-001, NFR-002]
│   ├── 5.2  Implement environment variable config
│   ├── 5.3  Implement input validation layer  [NFR-004]
│   └── 5.4  Enforce TLS for all connections  [NFR-003]
│
├── 6.0  SDLC Agent Pipeline
│   ├── 6.1  Orchestrator Agent  [FR-003, FR-004, FR-005]
│   ├── 6.2  Analysis Agent
│   ├── 6.3  Requirements Agent
│   ├── 6.4  Planning Agent
│   ├── 6.5  Design Agent
│   ├── 6.6  Development Agent
│   ├── 6.7  Review Agent
│   ├── 6.8  Testing Agent
│   ├── 6.9  Deployment Agent
│   └── 6.10 Documentation Agent
│
├── 7.0  Testing
│   ├── 7.1  Write unit tests (target 80%+ coverage)  [NFR-007]
│   ├── 7.2  Write integration tests
│   ├── 7.3  Write security tests  [NFR-001]
│   ├── 7.4  Write self-healing fault injection tests  [NFR-005]
│   ├── 7.5  Write hook validation tests  [FR-006, FR-007]
│   └── 7.6  Write end-to-end tests
│
├── 8.0  CI/CD Pipeline
│   ├── 8.1  Design GitHub Actions workflow  [FR-013]
│   ├── 8.2  Implement secret-scan stage  [FR-014]
│   ├── 8.3  Implement build stage
│   ├── 8.4  Implement test stage  [FR-015]
│   ├── 8.5  Implement deploy stage  [OQ-005]
│   └── 8.6  Implement rollback procedure
│
└── 9.0  Documentation
    ├── 9.1  Write README.md
    ├── 9.2  Write API reference
    ├── 9.3  Write architecture overview
    ├── 9.4  Write operational runbook
    └── 9.5  Write developer onboarding guide
```

---

## 2. Task Estimates & Owners

| Task ID | Task                              | Owner        | Estimate | Depends On     |
|---------|-----------------------------------|--------------|----------|----------------|
| 1.1     | Initialise repository structure   | Developer    | 0.5 day  | —              |
| 1.2     | Configure build tool              | Developer    | 0.5 day  | OQ-002 resolved|
| 1.3     | Set Java version                  | Developer    | 0.5 day  | OQ-004 resolved|
| 1.4     | Configure .gitignore              | Developer    | 0.5 day  | 1.1            |
| 2.1     | Design secret detection hook      | Developer    | 0.5 day  | 1.2            |
| 2.2     | Implement secret detection hook   | Developer    | 1 day    | 2.1            |
| 2.3     | Design connection validation hook | Developer    | 0.5 day  | OQ-003 resolved|
| 2.4     | Implement connection validation   | Developer    | 1 day    | 2.3            |
| 2.5     | Write hook install script         | Developer    | 0.5 day  | 2.2, 2.4       |
| 2.6     | Test hooks                        | QA           | 1 day    | 2.5            |
| 3.1     | Design retry logic                | Developer    | 0.5 day  | 4.1            |
| 3.2     | Implement RetryWrapper            | Developer    | 1 day    | 3.1            |
| 3.3     | Design circuit breaker            | Developer    | 0.5 day  | 4.1            |
| 3.4     | Implement CircuitBreaker          | Developer    | 1 day    | 3.3            |
| 3.5     | Design fallback handlers          | Developer    | 0.5 day  | 4.1            |
| 3.6     | Implement fallback handlers       | Developer    | 1 day    | 3.5            |
| 4.1     | Design system architecture        | Developer    | 1 day    | Requirements   |
| 4.2     | Design components                 | Developer    | 1 day    | 4.1            |
| 4.3     | Design data models                | Developer    | 1 day    | 4.1            |
| 4.4     | Design API contracts              | Developer    | 1 day    | OQ-003 resolved|
| 4.5     | Implement components              | Developer    | 3 days   | 4.2, 4.3       |
| 4.6     | Implement data access layer       | Developer    | 2 days   | 4.3            |
| 4.7     | Implement API/service layer       | Developer    | 2 days   | 4.4, 4.5       |
| 4.8     | Implement health check endpoint   | Developer    | 0.5 day  | 4.7            |
| 5.1     | Design secret management          | Developer    | 0.5 day  | 4.1            |
| 5.2     | Implement env var config          | Developer    | 0.5 day  | 5.1            |
| 5.3     | Implement input validation        | Developer    | 1 day    | 4.5            |
| 5.4     | Enforce TLS connections           | Developer    | 0.5 day  | 4.7            |
| 7.1     | Write unit tests                  | QA/Developer | 2 days   | 4.5, 4.6, 4.7  |
| 7.2     | Write integration tests           | QA           | 2 days   | 7.1            |
| 7.3     | Write security tests              | QA           | 1 day    | 5.2, 5.3, 5.4  |
| 7.4     | Write self-healing tests          | QA           | 1 day    | 3.2, 3.4, 3.6  |
| 7.5     | Write hook tests                  | QA           | 1 day    | 2.6            |
| 7.6     | Write E2E tests                   | QA           | 2 days   | 7.1, 7.2       |
| 8.1     | Design GitHub Actions workflow    | DevOps       | 0.5 day  | Requirements   |
| 8.2     | Implement secret-scan stage       | DevOps       | 0.5 day  | 8.1, 2.2       |
| 8.3     | Implement build stage             | DevOps       | 0.5 day  | 8.1, 1.2       |
| 8.4     | Implement test stage              | DevOps       | 0.5 day  | 8.3, 7.1       |
| 8.5     | Implement deploy stage            | DevOps       | 1 day    | 8.4, OQ-005    |
| 8.6     | Implement rollback procedure      | DevOps       | 1 day    | 8.5            |
| 9.1     | Write README.md                   | Developer    | 0.5 day  | 4.7, 8.5       |
| 9.2     | Write API reference               | Developer    | 0.5 day  | 4.4            |
| 9.3     | Write architecture overview       | Developer    | 0.5 day  | 4.1            |
| 9.4     | Write operational runbook         | DevOps       | 1 day    | 8.6            |
| 9.5     | Write developer guide             | Developer    | 0.5 day  | 9.1            |

**Total Estimate:** ~36 days (subject to revision once OQ-001–OQ-005 are resolved)

---

## 3. Milestones

| Milestone | Description                                              | Completion Criteria                                              | Phase Gate |
|-----------|----------------------------------------------------------|------------------------------------------------------------------|------------|
| M1        | Project Setup Complete                                   | Repo structure, build config, Java version set                   | ✅ User approval |
| M2        | Pre-Commit Hooks Live                                    | Secret + connection hooks active and tested                      | ✅ User approval |
| M3        | Self-Healing Utilities Ready                             | RetryWrapper, CircuitBreaker, Fallback implemented & tested      | ✅ User approval |
| M4        | Design Complete                                          | All 6 design docs in `design/` approved                         | ✅ User approval |
| M5        | Core Application Built                                   | All components, data, API, security layers implemented           | ✅ User approval |
| M6        | Code Review Passed                                       | Zero FAIL items in `review/review-report.md`                    | ✅ User approval |
| M7        | All Tests Pass                                           | ≥80% coverage, zero test failures, self-healing tests pass       | ✅ User approval |
| M8        | CI/CD Pipeline Active                                    | GitHub Actions running on push to main                           | ✅ User approval |
| M9        | Deployment Complete                                      | Application deployed, smoke tests pass, rollback verified        | ✅ User approval |
| M10       | Documentation Complete                                   | All 5 doc files complete, no secrets in docs                     | ✅ User approval |

---

## 4. Critical Path

```
Requirements → Design (4.1) → Components (4.5) → API Layer (4.7)
    → Unit Tests (7.1) → Integration Tests (7.2) → E2E Tests (7.6)
    → CI/CD Test Stage (8.4) → Deploy Stage (8.5) → Deployment Complete
```

**Critical path length:** ~18 days (longest chain of sequential dependencies)

---

## 5. Risk Mitigation Tasks

| Risk (from analysis)                  | Mitigation Task              | Owner     | Deadline      |
|---------------------------------------|------------------------------|-----------|---------------|
| Hardcoded credentials in code         | Task 2.2 + 8.2 (hooks + CI) | Developer | Before M5     |
| Broken API connections                | Task 2.4 (connection hook)   | Developer | Before M2     |
| Automation failures                   | Task 3.2, 3.4, 3.6           | Developer | Before M3     |
| Confluence URL resolved               | OQ-001 resolved              | Owner     | Done          |
| Unknown deployment environment        | OQ-005 — must resolve        | DevOps    | Before M8     |

---

## 6. Open Question Resolution Blockers

| OQ ID  | Question                                  | Blocks               |
|--------|-------------------------------------------|----------------------|
| OQ-001 | Confluence page URL                       | Resolved             |
| OQ-002 | Build tool: Maven or Gradle               | M1, all builds       |
| OQ-003 | External APIs / databases                 | API design, hooks    |
| OQ-004 | Java version                              | M1, build config     |
| OQ-005 | Target deployment environment             | M8, M9               |

---

## 7. Next Phase
➡️ **Design** — System architecture, component design, data models, API contracts, security & hook design.
