# Deployment Log

**Project:** GIthubCopilotCapstone

| Timestamp            | Event                    | Environment | Version  | Status     | Notes                                          |
|----------------------|--------------------------|-------------|----------|------------|------------------------------------------------|
| 2026-07-28T16:14:51Z | CI/CD pipeline created   | —           | 1.0.0-SNAPSHOT | CONFIGURED | GitHub Actions workflow ready                |
| 2026-07-28T16:14:51Z | Deployment phase created | —           | 1.0.0-SNAPSHOT | PENDING    | OQ-005 (deployment target) must be resolved  |
| 2026-07-29T06:55:00Z | Render configured | production | 1.0.0-SNAPSHOT | READY     | `Dockerfile` + `render.yaml` created. CI/CD deploy stage updated. OQ-004 ✅ resolved. |

---

## Pipeline Stage Status

| Stage         | Status      | Notes                                               |
|---------------|-------------|-----------------------------------------------------|
| Secret Scan   | ✅ READY    | Hook + CI scan configured                           |
| Build         | ✅ READY    | Maven + Java 20 (upgrade to 21 pending JDK install) |
| Test          | ✅ READY    | 74/74 tests pass, ≥80% coverage                    |
| Deploy        | ✅ READY    | Render deploy hook configured. `render.yaml` + `Dockerfile` ready.         |
| Smoke Test    | ✅ READY    | Uses `RENDER_APP_URL` secret → `https://officecheck-api.onrender.com/health` |
| Rollback      | ✅ READY    | Render API rollback to previous deploy on smoke test failure                 |

---

## Required Actions Before First Deploy

- [x] Resolve OQ-004: deployment target → **Render** ✅
- [ ] Set GitHub Actions secrets: `RENDER_DEPLOY_HOOK_URL`, `RENDER_API_KEY`, `RENDER_SERVICE_ID`, `RENDER_APP_URL`
- [ ] Connect GitHub repo to Render dashboard (auto-deploys via `render.yaml`)
- [ ] Resolve OQ-005: SMTP provider for host email notifications
