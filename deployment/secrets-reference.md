# Required GitHub Actions Secrets — Render Deployment

This file documents the GitHub repository secrets that must be configured
in **Settings → Secrets and variables → Actions** before the CI/CD pipeline can deploy to Render.

> ⚠️ **NEVER commit actual secret values to this file or any other file.**
> These are reference names only.

---

## Render Secrets (Required for Deploy)

| Secret Name              | Purpose                                                  | Where to get it |
|--------------------------|----------------------------------------------------------|-----------------|
| `RENDER_DEPLOY_HOOK_URL` | Webhook URL to trigger a Render redeploy                 | Render Dashboard → officecheck-api → Settings → Deploy Hook |
| `RENDER_API_KEY`         | Render API key for deploy status polling and rollback    | Render Dashboard → Account Settings → API Keys |
| `RENDER_SERVICE_ID`      | Render service ID for the officecheck-api service        | Render Dashboard → officecheck-api → Settings → Service ID |
| `RENDER_APP_URL`         | Deployed application base URL for smoke test             | `https://officecheck-api.onrender.com` |

## Application Secrets (Set in Render Dashboard, not GitHub)

These are configured directly in Render (Dashboard → officecheck-api → Environment):

| Variable Name      | Purpose                              |
|--------------------|--------------------------------------|
| `EXTERNAL_API_URL` | Base URL for external API            |
| `EXTERNAL_API_KEY` | API key for external service         |
| `APP_ENV`          | Set to `production`                  |

> ℹ️ `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` are injected automatically by Render from the PostgreSQL add-on — no manual configuration needed when using `render.yaml`.

---

## How to Set GitHub Secrets

```bash
# Using GitHub CLI
gh secret set RENDER_DEPLOY_HOOK_URL   # paste hook URL when prompted
gh secret set RENDER_API_KEY           # paste API key when prompted
gh secret set RENDER_SERVICE_ID        # paste service ID when prompted
gh secret set RENDER_APP_URL --body "https://officecheck-api.onrender.com"
```

---

## Self-Healing Configuration (Optional — set in Render Dashboard)

| Variable              | Purpose                              | Default  |
|-----------------------|--------------------------------------|----------|
| `RETRY_MAX_ATTEMPTS`  | Max retry attempts per call          | `3`      |
| `RETRY_BASE_DELAY_MS` | Base retry delay in milliseconds     | `1000`   |
| `CB_FAILURE_THRESHOLD`| Failures before circuit opens        | `3`      |
| `CB_RESET_TIMEOUT_MS` | Circuit reset cooldown (ms)          | `30000`  |

---

## Render Dashboard Reference

| Action                        | URL |
|-------------------------------|-----|
| Service overview              | https://dashboard.render.com/web/officecheck-api |
| Deploy history & rollback     | https://dashboard.render.com/web/officecheck-api/deploys |
| Environment variables         | https://dashboard.render.com/web/officecheck-api/env |
| Logs                          | https://dashboard.render.com/web/officecheck-api/logs |

