# Deployment Agent

## Runnable Role
Handles deployment using `prompts/deployment/deployment-prompt.md`.

## Inputs
- `testing/test-report.md`
- `src/` compiled artifact
- `design/security-design.md`

## Outputs
- `.github/workflows/ci-cd.yml`
- `deployment/deployment-log.md`
