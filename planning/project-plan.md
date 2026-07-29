# Project Plan — OfficeCheck

**Project:** OfficeCheck – Digital Visitor Sign-In & Lobby Manager
**Phase:** Planning
**Source:** Confluence Requirements + Jira KAN (4 Epics, 12 Stories, 24 Tasks)
**Status:** COMPLETE
**Last Updated:** 2026-07-29

---

## 1. Work Breakdown Structure (WBS)

```
OfficeCheck
├── 1.0  Infrastructure & Setup
│   ├── 1.1  GitHub repo + branch protection rules
│   ├── 1.2  Maven 3.9.9, Java 20 (Corretto), Spring Boot 3.2
│   ├── 1.3  Docker multi-stage build + render.yaml (Render PaaS)
│   ├── 1.4  Pre-commit hooks (secret scan + connection validation)
│   └── 1.5  GitHub Actions CI/CD (5 stages)
│
├── 2.0  Visitor Sign-In Module  [KAN-445]
│   ├── 2.1  Visitor sign-in form — name, company, host (KAN-449)
│   ├── 2.2  Server-side input validation (KAN-462)
│   ├── 2.3  Persist visitor record to DB (KAN-463)
│   └── 2.4  Responsive UI for tablet/browser (KAN-450)
│
├── 3.0  Host Notification Module  [KAN-446]
│   ├── 3.1  Email notification service on check-in (KAN-451)
│   ├── 3.2  SMTP config via env vars (KAN-467)
│   ├── 3.3  Notification content (name + timestamp) (KAN-452)
│   └── 3.4  Integration test — notification within 60s (KAN-468)
│
├── 4.0  Check-In / Check-Out Module  [KAN-447]
│   ├── 4.1  Store ISO-8601 check-in timestamp (KAN-453)
│   ├── 4.2  GET /visitors/{id} API (KAN-471)
│   ├── 4.3  PATCH /visitors/{id}/checkout endpoint (KAN-454)
│   └── 4.4  Status transition CHECKED_IN → CHECKED_OUT (KAN-473)
│
├── 5.0  Manager Dashboard Module  [KAN-448]
│   ├── 5.1  GET /visitors/active API (KAN-455)
│   ├── 5.2  Real-time polling every 5s (KAN-475)
│   ├── 5.3  Active vs checked-out filter (KAN-456)
│   └── 5.4  History tab (KAN-477)
│
├── 6.0  Self-Healing & Security  [KAN-445 NFRs]
│   ├── 6.1  RetryWrapper — exponential backoff (KAN-481)
│   ├── 6.2  CircuitBreaker — CLOSED/OPEN/HALF_OPEN (KAN-482)
│   ├── 6.3  FallbackHandler — degraded mode (KAN-483)
│   ├── 6.4  HTTPS enforcement in ExternalApiClient (KAN-480)
│   └── 6.5  Secret scan hook + CI/CD stage (KAN-478, KAN-479)
│
└── 7.0  Testing & Deployment
    ├── 7.1  Unit tests (≥80% coverage, JaCoCo)
    ├── 7.2  Integration tests (H2 in-memory)
    ├── 7.3  Load test — p95 < 500ms at 100 users (KAN-484)
    ├── 7.4  Deploy to Render via GitHub Actions
    └── 7.5  Smoke test + auto-rollback
```

---

## 2. Sprint Plan

| Sprint | Stories | Goal |
|--------|---------|------|
| Sprint 1 (Week 1–2) | KAN-449, KAN-450, KAN-453, KAN-454 | Visitor sign-in + check-in/out working end-to-end |
| Sprint 2 (Week 3–4) | KAN-451, KAN-452, KAN-455, KAN-456 | Host notification + manager dashboard live |
| Sprint 3 (Week 5–6) | KAN-457, KAN-458, KAN-459, KAN-460 | NFRs: security, self-healing, performance |
| Sprint 4 (Week 7)   | Deploy, smoke test, documentation    | Production deploy on Render + docs complete |

---

## 3. Milestones

| # | Milestone | Target Date | Gate Condition |
|---|-----------|-------------|----------------|
| M1 | Analysis Complete    | 2026-07-29 | `project-scoping/analysis.md` STATUS: COMPLETE ✅ |
| M2 | Requirements Complete| 2026-07-29 | `requirements-spec.md` + 40 Jira issues created ✅ |
| M3 | Planning Complete    | 2026-07-29 | Plan published to GitLab ✅ |
| M4 | Design Complete      | 2026-08-05 | 6 design docs approved |
| M5 | Development Complete | 2026-08-19 | All FRs implemented, 74+ tests pass |
| M6 | Review Complete      | 2026-08-21 | 0 FAIL in review report |
| M7 | Testing Complete     | 2026-08-23 | ≥80% coverage, 0 failures |
| M8 | Deployed to Render   | 2026-08-26 | Smoke test PASS on production URL |
| M9 | Documentation Done   | 2026-08-28 | README + docs/ complete |

---

## 4. Risk Mitigation Tasks

| Risk | Mitigation Task | Owner | Sprint |
|------|----------------|-------|--------|
| SMTP provider not configured | Add SMTP_HOST/USER/PASS to .env; use Mailtrap for testing | Dev | Sprint 2 |
| Render cold starts (free tier) | Implement /health keep-alive ping; document in runbook | DevOps | Sprint 4 |
| Dashboard performance under load | Load test KAN-484; add DB index on status+checkin_time | Dev | Sprint 3 |
| Visitor data privacy | Input validation + no raw data logging + HTTPS enforced | Dev | Sprint 1 |
| GitLab publish fails | Log error, continue — local plan always created first | Planning Agent | Sprint 1 |

---

## 5. Dependencies

```
KAN-449 (Sign-in form) 
  → KAN-451 (Host notification — needs visitor record)
  → KAN-453 (Check-in timestamp — needs visitor record)

KAN-453 (Check-in)
  → KAN-454 (Check-out — needs check-in first)
  → KAN-455 (Dashboard active list — needs status field)

KAN-455 (Active list API)
  → KAN-456 (Dashboard filter — needs API)
```

---

## 6. Team & Ownership

| Role | Responsibility |
|------|---------------|
| Developer | All FRs (KAN-449 to KAN-456), NFRs (KAN-457–460) |
| DevOps | Render setup, GitHub Actions, Docker |
| QA | Test cases, coverage gate, load test |
| Scrum Master | Sprint ceremonies, Jira board hygiene |
