# GIthubCopilotCapstone

End-to-end SDLC capstone project with analysis, requirements, planning, design, development, review, testing, deployment, and documentation artifacts.

## What it includes
- Runnable agents in `agents/`
- Prompt instructions in `prompts/`
- Skill definitions in `skills/`
- Requirements and traceability in `requirements/`
- Analysis/scoping in `project-scoping/`
- Design docs in `design/`
- Java 17 Maven application in `src/`
- Pre-commit hooks in `.github/hooks/` and `setup.sh`
- CI/CD workflow in `.github/workflows/ci-cd.yml`

## Prerequisites
- Java 20
- Maven 3.9+
- Git

## Setup
```sh
sh setup.sh
```

Create a local `.env` file from `.env.example` and fill in the real values:
```sh
copy .env.example .env
```

## Run the Orchestrator

### Interactive Mode (local — HITL gate pauses at each phase for human approval)
**Mac / Linux:**
```sh
set -a && source .env && set +a
bash .github/hooks/agent-pre-run-hook.sh OrchestratorAgent
```
**Windows (PowerShell):**
```powershell
.\run-orchestrator.ps1
```
> This starts the precheck and then launches an interactive Copilot orchestrator session.

---

### Pipeline Mode (CI/CD — all phase gates auto-approve, no human input)
**Mac / Linux:**
```sh
set -a && source .env && set +a
INTERACTIVE_MODE=false bash .github/hooks/agent-pre-run-hook.sh OrchestratorAgent
```
**Windows (PowerShell):**
```powershell
.\run-orchestrator.ps1 -PipelineMode
```
> Pipeline mode also triggers automatically on `git push origin main` via GitHub Actions.

---

## Run locally
Set the required environment variables in `.env` or your system environment:
- `CONFLUENCE_URL`
- `CONFLUENCE_API_TOKEN`
- `CONFLUENCE_EMAIL`
- `GITHUB_TOKEN`
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `EXTERNAL_API_URL`
- `EXTERNAL_API_KEY`
- `APP_PORT` (optional)
- `APP_ENV` (optional)

Then build and run:
```sh
mvn clean package
java -jar target/github-copilot-capstone-1.0.0-SNAPSHOT.jar
```

## Test
```sh
mvn test
```

## Hooks
- `pre-commit-secrets` blocks hardcoded secrets
- `pre-commit-connect` validates required connections
- `OFFLINE_MODE=true` skips connection validation for offline work

## Self-healing
- Retry with exponential backoff
- Circuit breaker
- Fallback handling for unavailable dependencies

## Documentation
- Analysis: `project-scoping/analysis.md`
- Requirements: `requirements/requirements-spec.md`
- Planning: `planning/project-plan.md`
- Design: `design/`
- Review: `review/review-report.md`
- Testing: `testing/test-report.md`
- Deployment: `deployment/deployment-log.md`
- Agents: `agents/`
- Prompts: `prompts/`
- Skills: `skills/`
- Workflow: `project-workflow.md`

## Deployment
Triggered automatically by pushing to `main` via GitHub Actions CI/CD pipeline.


## What it includes
- Runnable agents in `agents/`
- Prompt instructions in `prompts/`
- Skill definitions in `skills/`
- Requirements and traceability in `requirements/`
- Analysis/scoping in `project-scoping/`
- Design docs in `design/`
- Java 17 Maven application in `src/`
- Pre-commit hooks in `.github/hooks/` and `setup.sh`
- CI/CD workflow in `.github/workflows/ci-cd.yml`

## Prerequisites
- Java 20
- Maven 3.9+
- Git

## Setup
```sh
sh setup.sh
```

Create a local `.env` file from `.env.example` and fill in the real values:
```sh
copy .env.example .env
```

## Run locally
Set the required environment variables in `.env` or your system environment:
- `CONFLUENCE_URL`
- `CONFLUENCE_API_TOKEN`
- `CONFLUENCE_EMAIL`
- `GITHUB_TOKEN`
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `EXTERNAL_API_URL`
- `EXTERNAL_API_KEY`
- `APP_PORT` (optional)
- `APP_ENV` (optional)

Then build and run:
```sh
mvn clean package
java -jar target/github-copilot-capstone-1.0.0-SNAPSHOT.jar
```

## Test
```sh
mvn test
```

## Hooks
- `pre-commit-secrets` blocks hardcoded secrets
- `pre-commit-connect` validates required connections
- `OFFLINE_MODE=true` skips connection validation for offline work

## Self-healing
- Retry with exponential backoff
- Circuit breaker
- Fallback handling for unavailable dependencies

## Documentation
- Analysis: `project-scoping/analysis.md`
- Requirements: `requirements/requirements-spec.md`
- Planning: `planning/project-plan.md`
- Design: `design/`
- Review: `review/review-report.md`
- Testing: `testing/test-report.md`
- Deployment: `deployment/deployment-log.md`
- Agents: `agents/`
- Prompts: `prompts/`
- Skills: `skills/`

## Deployment
Deployment is configured in `.github/workflows/ci-cd.yml`, but the actual target command is still pending OQ-005.
