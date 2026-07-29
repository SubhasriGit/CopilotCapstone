# Developer Guide

## Setup
```sh
sh setup.sh
```

## Build
```sh
mvn clean package
```

## Test
```sh
mvn test
```

## Development rules
- Never hardcode secrets or passwords
- Use `ConfigLoader` for environment variables
- Route all external calls through `RetryWrapper` + `CircuitBreaker`
- Validate input with `InputValidator`
- Keep connection validation enabled

## Project structure
- `project-scoping/analysis.md`
- `requirements/requirements-spec.md`
- `planning/project-plan.md`
- `design/`
- `src/main/java/com/capstone/`
- `src/test/java/com/capstone/`

## Hooks
- Secret scan blocks secret leakage
- Connection validation blocks broken connections
- Use `OFFLINE_MODE=true` only when working offline

