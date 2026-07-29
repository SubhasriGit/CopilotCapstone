# Deployment Log

**Project:** OfficeCheck
**Target Platform:** Render (https://officecheck-api.onrender.com)
**Deployment Phase Status:** COMPLETE (configuration + documentation)

## 1. Deployment Checklist

- [x] Verified `testing/test-report.md` reports **74/74 tests passed**
- [x] Confirmed test report contains no exposed credentials, API keys, or tokens
- [x] Reviewed `design/security-design.md` for secret handling, validation, TLS, and log-masking requirements
- [x] Validated local `.env` is configured for offline/local testing with placeholder values only
- [x] Configured GitHub Actions CI/CD workflow for build, test, security, deploy, smoke test, and rollback
- [x] Confirmed Render deployment target URL and production environment variables
- [x] Documented manual approval requirement for production deployments

## 2. Pre-Deployment Validation Steps

1. Open `testing/test-report.md` and confirm the status line shows **ALL TESTS PASSED**.
2. Verify the totals table shows **74 passed, 0 failed, 0 errors, 0 skipped**.
3. Review `design/security-design.md` to confirm:
   - secrets must come from environment variables,
   - logs must not expose secrets,
   - CI/CD must perform secret scanning.
4. Check `.env` for local readiness:
   - `APP_PORT=8080`
   - `APP_ENV=local`
   - Render-related values are placeholders for offline testing, not live secrets.
5. Confirm `render.yaml` sets production deployment values:
   - `APP_PORT=8080`
   - `APP_ENV=production`
   - `healthCheckPath: /health`
6. Confirm `src/main/resources/application.properties` enables:
   - graceful shutdown,
   - health probes,
   - console logging for Render.

## 3. CI/CD Pipeline Summary

Workflow: `.github/workflows/ci-cd.yml`

### Triggers
- Push to `main`
- Pull request targeting `main`
- Manual `workflow_dispatch`

### Stages
1. **Build** — `mvn clean install -DskipTests` on Corretto 20 and publish JAR artifact.
2. **Test** — `mvn test jacoco:report jacoco:check`.
3. **Security**
   - hardcoded-secret scan over deployable source/config files,
   - OWASP dependency check with build failure on high-severity findings.
4. **Deploy** — runs only on `main` pushes after successful test and security stages.
5. **Smoke Test** — validates `/health` and primary API reachability.
6. **Rollback** — automatically attempts rollback if smoke tests fail after deploy.

## 4. Production Deployment Procedure

1. Ensure repository secrets are configured in GitHub Actions:
   - `RENDER_DEPLOY_HOOK_URL`
   - `RENDER_API_KEY`
   - `RENDER_SERVICE_ID`
2. Optional repository variable:
   - `RENDER_APP_URL` (defaults to `https://officecheck-api.onrender.com` if unset)
3. In GitHub, configure the **production** environment with **required reviewers** for manual approval.
4. Merge approved code into `main`.
5. GitHub Actions builds, tests, scans, and then pauses for production approval.
6. After approval, the workflow triggers the Render deploy hook.
7. The workflow polls Render until the new deploy becomes live.
8. Smoke tests run against the live Render URL.

## 5. Post-Deployment Verification / Smoke Tests

The workflow verifies the deployment within the first 30 seconds after service availability:

- `GET /health` returns **200 OK**
- Health payload reports `status = UP`
- `GET /api/v1/entities` responds successfully as the primary API smoke test
- `GET /api/visitors` is treated as optional:
  - **200/204/401/403** = reachable,
  - **404** = not implemented, skipped,
  - anything else = failure

Manual verification commands:

```bash
curl -i https://officecheck-api.onrender.com/health
curl -i https://officecheck-api.onrender.com/api/v1/entities
curl -i https://officecheck-api.onrender.com/api/visitors
```

## 6. Rollback Procedure

### Automated
If smoke tests fail after a successful deploy job, the workflow:
1. queries recent Render deploys,
2. selects the previous deploy ID,
3. calls the Render rollback endpoint.

### Manual
If automated rollback cannot determine a previous deploy:
1. Open Render Dashboard → `officecheck-api` → **Deploys**
2. Select the previous healthy deployment
3. Click **Rollback**
4. Re-run smoke tests:
   - `/health`
   - `/api/v1/entities`

Helper script: `deployment/rollback.sh`

## 7. Render Deployment Strategy

- **Platform:** Render web service (`officecheck-api`)
- **Build artifact:** Spring Boot executable JAR packaged by Maven
- **Container:** `Dockerfile` using Corretto 20 runtime
- **Environment variables:** managed in Render / GitHub secrets, never committed
- **Health check:** `GET /health`
- **Shutdown:** Spring Boot graceful shutdown with 20-second timeout and `SIGTERM` handling
- **Logging:** stdout/stderr only so logs flow directly into Render log streams
- **Auto deploy:** disabled in `render.yaml`; deployments are released through GitHub Actions after manual approval

## 8. Known Issues and Resolutions

| Issue | Resolution |
|---|---|
| Render free tier may cold-start after inactivity | Smoke tests retry for up to 30 seconds before failing |
| Production deployment must not bypass approval | `render.yaml` disables auto deploy and workflow uses GitHub `production` environment |
| False positives in secret scanning from documentation regex examples | Security scan is limited to deployable source/config/script paths |
| Rollback requires Render API access | Workflow and helper script require `RENDER_API_KEY` and `RENDER_SERVICE_ID` |

## 9. Readiness Outcome

Deployment configuration is ready for execution. The repository now contains:
- a GitHub Actions CI/CD pipeline,
- Render production configuration,
- smoke-test automation,
- rollback automation,
- deployment runbook documentation.