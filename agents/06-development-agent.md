# Development Agent

## Runnable Role
Implements the application **and** performs an inline code review upon completion.
Uses `prompts/07-development.md` and `skills/07-development.md`.

## Pre-Run Hook (Mandatory)
```bash
source .env && bash .github/hooks/agent-pre-run-hook.sh DevelopmentAgent
```

## Inputs
- All files in `design/`
- `requirements/requirements-spec.md`
- `planning/project-plan.md`

## Outputs
- `src/` — Java 20 source code (production + tests)
- `.github/hooks/` — pre-commit hook scripts
- `review/review-report.md` — inline review findings (PASS / WARN / FAIL)
- Build config (`pom.xml`, `Dockerfile`, `render.yaml`)

## Execution Steps
1. Run pre-run hook (Orchestrator responsibility).
2. Read all `design/` docs for implementation guidance.
3. Implement Java source files under `src/main/java/` and `src/test/java/`.
4. Implement pre-commit hook scripts under `.github/hooks/`.
5. Apply retry, circuit breaker, and fallback patterns on all external calls.
6. **Inline Code Review** — upon completing implementation:
   - Scan for hardcoded secrets, insecure patterns, and design drift.
   - Verify all external calls have self-healing logic.
   - Verify pre-commit hooks are present and functional.
   - Write findings to `review/review-report.md` (PASS / WARN / FAIL per finding).
   - Any FAIL finding must be fixed before reporting `STATUS: COMPLETE`.
7. Report `STATUS: COMPLETE` to the Orchestrator.

## Review Criteria (Inline)
| Check | Severity | Pass Condition |
|---|---|---|
| No hardcoded secrets | FAIL | Zero secret literals in any file |
| All external calls self-healed | FAIL | Retry + circuit breaker on every external call |
| Hooks present and functional | FAIL | `pre-commit-secrets` and `pre-commit-connect` exist |
| Design compliance | WARN | Implementation matches approved design docs |
| Code quality / maintainability | WARN | No dead code, clear naming, adequate comments |

## Last Run
| Field | Value |
|---|---|
| Status | ⏳ Pending |
