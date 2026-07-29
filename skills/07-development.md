# Development Skills

| Skill | Definition |
|---|---|
| Java Development | Implements production Java 20 code — models, services, controllers, repositories |
| Hook Implementation | Writes `pre-commit-secrets` and `pre-commit-connect` hook scripts |
| Self-Healing Implementation | Adds retry (exponential backoff), circuit breaker (CLOSED/OPEN/HALF-OPEN), and fallback logic on all external calls |
| Secret Management | Uses environment variables for all credentials — never hardcoded literals |
| Build Configuration | Sets up Maven, `pom.xml`, `Dockerfile`, `render.yaml` |
| Code Quality | Clean naming, no dead code, adequate Javadoc comments |
| Secret Scan | Searches source files for hardcoded passwords, API keys, tokens, private keys |
| Security Review | Verifies TLS/HTTPS on all external calls, input validation, no sensitive data in logs |
| Design Compliance | Compares implementation against approved design docs (API contracts, data model, security design) |
| Hook Verification | Confirms pre-commit hooks exist, are executable, and function correctly |
| Self-Healing Verification | Confirms retry + circuit breaker is applied on every external service call |
| Review Report Writing | Produces `review/review-report.md` with FAIL / WARN / PASS findings per file |

