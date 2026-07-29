# Analysis Phase

**Agent:** AnalysisAgent  
**Run Date:** 2026-07-29  
**Status:** ✅ COMPLETE  
**Pre-Run Hook:** PASSED (secrets: 0, Confluence: HTTP 200, GitHub: HTTP 200)

---

## 1. Requirement Source
| Field          | Value |
|----------------|-------|
| Confluence Page | `https://subhasree.atlassian.net/wiki/spaces/~712020ff355f343c4d4b6b9b7cc6aa838aff7b/pages/14090241/Requirements` |
| Page Title     | Requirements |
| Space          | Subha |
| Page Version   | 3 |
| Fetched        | 2026-07-29 via Confluence REST API |

---

## 2. Project Overview
| Field            | Details                                                         |
|------------------|-----------------------------------------------------------------|
| Project Name     | OfficeCheck – Digital Visitor Sign-In & Lobby Manager           |
| Business Domain  | Facility Management / Office Security                           |
| Language         | Java 20 (Amazon Corretto)                                       |
| Build Tool       | Maven 3.9.9                                                     |
| IDE              | IntelliJ IDEA                                                   |
| Repository       | SubhasriGit/MCPRepo                                             |
| Jira Project     | KAN (mm-learning-group-1) — https://subhasree.atlassian.net     |
| Status           | Analysis Complete — Requirements sourced from Confluence        |

---

## 2a. Business Problem (from Confluence)
Physical office buildings, schools, and co-working spaces need to know exactly **who is in the building** at any given moment for security and fire safety.  
Paper logbooks at the front desk are:
- Messy and hard to read
- Not real-time
- A privacy risk for visitor data

**OfficeCheck** replaces paper logbooks with a digital, real-time visitor management system.

---

## 2b. E2E Business Flow (from Confluence)
1. A visitor arrives at the office lobby and enters their **name, company, and host** on a simple tablet screen.
2. The system automatically sends an **email/notification to the host** employee: *"Hi Alice, your visitor (John Doe) has arrived in the lobby."*
3. The system logs the **exact check-in time**. When leaving, the visitor **checks out**.
4. The building manager has a **dashboard** showing a real-time list of all active guests currently inside the building.

---

## 3. Stakeholder Analysis
| Stakeholder           | Role                    | Interest / Concern                                           |
|-----------------------|-------------------------|--------------------------------------------------------------|
| Visitor               | End User                | Simple, fast sign-in; privacy of personal data               |
| Host Employee         | Notification Recipient  | Timely notification when their visitor arrives               |
| Building Manager      | Dashboard User          | Real-time visibility of all guests in the building           |
| Front Desk / Admin    | Operator                | Digital replacement for paper logbook; audit trail           |
| Security / Fire Warden| Safety Officer          | Accurate headcount for emergency/evacuation                  |
| IT / DevOps           | Deployment & Ops        | Secure, reliable, cloud-deployable system                    |

---

## 4. Feasibility Analysis
| Dimension   | Assessment | Notes                                                                    |
|-------------|------------|--------------------------------------------------------------------------|
| Technical   | ✅ Feasible | Java 20 + Spring Boot 3.2 + H2/PostgreSQL; all tooling available locally |
| Operational | ✅ Feasible | IntelliJ IDEA + GitHub + Jira + Confluence workflow all connected        |
| Timeline    | Medium     | 4 business capabilities, 8 FRs, 4 NFRs; estimated 2–3 sprints           |
| Risk        | Low–Medium | See Risk Analysis below                                                  |

---

## 5. Scope

### In Scope
- **Visitor self-service sign-in** via tablet/web screen (name, company, host name)
- **Host notification** — automated email notification when visitor checks in
- **Check-in / check-out** timestamp logging with status tracking (CHECKED_IN / CHECKED_OUT)
- **Building manager dashboard** — real-time active guest list, history tab
- Pre-commit hooks — secret scanning + connection validation
- Self-healing automation (retry, circuit breaker, fallback)
- CI/CD pipeline (GitHub Actions — 5 stages)
- Jira story/task tracking (project KAN)

### Out of Scope
- Badge/ID printing
- Integration with physical access control hardware
- Visitor photo capture
- Multi-building / multi-site management (future phase)
- SMS/push notification (email only in this phase)

---

## 6. Risk Analysis
| Risk                                    | Likelihood | Impact | Mitigation                                            |
|-----------------------------------------|------------|--------|-------------------------------------------------------|
| Email provider misconfiguration         | Medium     | High   | Use env-var credentials; integration test in CI/CD    |
| Hardcoded credentials in code           | Low        | High   | Pre-commit hooks + CI secret scan (already in place)  |
| Broken API/DB connections at runtime    | Low        | High   | Agent pre-run hook validates connections before run   |
| Dashboard performance under load        | Medium     | Medium | NFR-004: p95 < 500ms; load test task KAN-484         |
| Visitor data privacy breach             | Low        | High   | Input validation + HTTPS enforced + no data logging   |
| Scope creep (photo, badge, multi-site)  | Medium     | Medium | Explicitly out-of-scope; confirmed at analysis gate   |

---

## 7. Assumptions
1. Build tool is **Maven 3.9.9** — confirmed (pom.xml exists).
2. Java version is **20 (Amazon Corretto)** — confirmed locally.
3. Secrets managed via **environment variables** — never hardcoded.
4. Email notifications use an **SMTP provider** configured via env vars.
5. Database is **H2 (test) / configurable via DB_URL** for production.
6. CI/CD runs on **GitHub Actions** with 5 stages.

---

## 8. Open Questions
| ID     | Question                                          | Status     | Resolution |
|--------|---------------------------------------------------|------------|------------|
| OQ-001 | What is the Confluence page URL?                  | ✅ Resolved | `pages/14090241/Requirements` |
| OQ-002 | Is the build tool Maven or Gradle?                | ✅ Resolved | Maven 3.9.9 |
| OQ-003 | What external APIs or databases?                  | ✅ Resolved | SMTP (email), H2/PostgreSQL (DB) |
| OQ-004 | What is the target deployment environment?        | ✅ Resolved | **Render** (cloud PaaS) — Docker container via `render.yaml` + `Dockerfile` |
| OQ-005 | What SMTP provider for host notifications?        | ⚠️ Open    | Needs SMTP_HOST, SMTP_USER, SMTP_PASS in .env |

---

## 9. Agent Report to Orchestrator

```
AGENT      : AnalysisAgent
PHASE      : Analysis
STATUS     : COMPLETE
HOOK       : PASSED
DELIVERABLE: project-scoping/analysis.md (updated 2026-07-29)
OPEN ITEMS : OQ-005 (SMTP provider) — non-blocking; OQ-004 ✅ resolved (Render)
NEXT PHASE : Requirements ✅ (already complete — KAN-449 to KAN-484 created in Jira)
```


---

## 2. Project Overview
| Field            | Details                                                         |
|------------------|-----------------------------------------------------------------|
| Project Name     | OfficeCheck – Digital Visitor Sign-In & Lobby Manager           |
| Business Domain  | Facility Management / Office Security                           |
| Language         | Java                                                            |
| Build Tool       | Maven                                                           |
| IDE              | IntelliJ IDEA                                                   |
| Repository       | SubhasriGit/MCPRepo                                             |
| Confluence Source| https://subhasree.atlassian.net/wiki/spaces/~712020ff355f343c4d4b6b9b7cc6aa838aff7b/pages/14090241/Requirements |
| Status           | Analysis Complete — Requirements sourced from Confluence        |

---

## 2a. Business Problem
Physical office buildings, schools, and co-working spaces need to know exactly **who is in the building** at any given moment for security and fire safety.  
Paper logbooks at the front desk are:
- Messy and hard to read
- Not real-time
- A privacy risk for visitor data

**OfficeCheck** replaces paper logbooks with a digital, real-time visitor management system.

---

## 3. Stakeholder Analysis
| Stakeholder          | Role                    | Interest / Concern                                           |
|----------------------|-------------------------|--------------------------------------------------------------|
| Visitor              | End User                | Simple, fast sign-in experience; privacy of personal data    |
| Host Employee        | Notification Recipient  | Timely notification when their visitor arrives               |
| Building Manager     | Dashboard User          | Real-time visibility of all guests currently in the building |
| Front Desk / Admin   | Operator                | Digital replacement for paper logbook; audit trail           |
| Security / Fire Warden| Safety Officer         | Accurate headcount in case of emergency/evacuation           |
| IT / DevOps          | Deployment & Ops        | Secure, reliable, cloud-deployable system                    |

---

## 4. Feasibility Analysis
| Dimension        | Assessment            | Notes                                      |
|------------------|-----------------------|--------------------------------------------|
| Technical        | Feasible              | Java stack, standard tooling               |
| Operational      | Feasible              | IntelliJ IDEA + GitHub workflow            |
| Timeline         | TBD                   | Depends on requirement complexity          |
| Risk             | Low–Medium            | See Risk Analysis below                    |

---

## 5. Scope
### In Scope
- **Visitor self-service sign-in** via tablet/web screen (name, company, host name)
- **Host notification** — automated email/push notification when visitor checks in
- **Check-in / check-out** timestamp logging
- **Building manager dashboard** — real-time list of all active guests
- End-to-end SDLC implementation (Analysis → Documentation)
- Pre-commit hooks to prevent hardcoded API keys / passwords
- Connection validation hooks
- Self-healing automation techniques (retry, circuit breaker, fallback)
- CI/CD pipeline integration

### Out of Scope
- Badge/ID printing
- Integration with physical access control hardware
- Visitor photo capture
- Multi-building / multi-site management (future phase)

---

## 6. Risk Analysis
| Risk                                   | Likelihood | Impact | Mitigation                                      |
|----------------------------------------|------------|--------|-------------------------------------------------|
| Confluence requirements not available  | High       | High   | Block progress until the source is available and validated |
| Hardcoded credentials in code          | Medium     | High   | Pre-commit hooks + secret scanning              |
| Broken API connections                 | Medium     | High   | Connection validation hooks at startup          |
| Automation failures                    | Low        | Medium | Self-healing retry logic                        |
| Scope creep                            | Medium     | Medium | Confirm scope at each SDLC phase                |

---

## 7. Assumptions
1. Requirements will be provided via the Confluence link before Design begins.
2. The project uses Java with Maven or Gradle (to be confirmed).
3. Secrets are managed via environment variables or a secrets manager — never hardcoded.
4. CI/CD will run pre-commit hooks and automated tests on every push.

---

## 8. Open Questions
- [x] What is the Confluence page URL?
- [ ] Is the build tool Maven or Gradle?
- [ ] What external APIs or databases will the project connect to?
- [ ] What is the target deployment environment (cloud, on-prem, container)?

---

## 9. Next Phase
➡️ **Requirements** — Review the configured Confluence source, then extract and document functional and non-functional requirements.
