# Architecture Overview

## Style
Layered N-tier architecture with cross-cutting security and self-healing layers.

## Layers
| Layer | Responsibility |
|---|---|
| API / Controller | Validate input and route requests |
| Service | Business logic and orchestration |
| Repository | Data access |
| Client | External API calls |
| Security | Input validation, secret handling, connection validation |
| Resilience | Retry, circuit breaker, fallback |
| Health | Expose `/health` |
| DevOps | Hooks, CI/CD, deploy and rollback |

## Key decisions
- Secrets are read from environment variables only
- External calls are wrapped in retry + circuit breaker
- Connections are validated at startup and before commit
- Maven is the build tool
- Java 20 is the current build target in this environment

## Package layout
```text
com.capstone.api
com.capstone.service
com.capstone.repository
com.capstone.model
com.capstone.client
com.capstone.resilience
com.capstone.security
com.capstone.health
com.capstone.config
```

## Open items
- Deployment target is still pending
- Final domain entities may change after Confluence requirements are provided

