# Runbook

## Deploy
1. Ensure `mvn test` passes.
2. Set GitHub Actions secrets from `deployment/secrets-reference.md`.
3. Resolve deployment target (OQ-005).
4. Run the deploy workflow.

## Rollback
If smoke tests fail:
1. Stop the release.
2. Restore the last known good version.
3. Re-run the health check.

## Health check
Use:
```sh
curl <app-url>/health
```

Expected:
- `200` and `status=UP` when healthy
- `503` and `status=DEGRADED` when dependencies are down

## Incident response
- Check `deployment/deployment-log.md`
- Review `review/review-report.md`
- Inspect `target/surefire-reports/` and `target/site/jacoco/`
- Verify connection and secret environment variables

