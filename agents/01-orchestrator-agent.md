# Orchestrator Agent

## Runnable Role
Coordinates all SDLC phase agents using `prompts/01-orchestrator.md`.  
Enforces pre-run hooks, HITL phase gates, and pipeline logging.

## Execution Modes
| `INTERACTIVE_MODE` | Behaviour |
|---|---|
| `true` | **Interactive** — HITL gate pauses at every phase transition and waits for human approval |
| `false` / unset | **Pipeline** — HITL gate auto-approves all transitions; no human input needed |

## Pre-Run Hook
Before invoking **any** phase agent, the Orchestrator MUST execute:
```bash
source .env && bash .github/hooks/agent-pre-run-hook.sh <AgentName>
```
- Exit 1 → BLOCKED: hardcoded secret found — abort, alert user, do not proceed.
- Exit 2 → BLOCKED: required connection unavailable — abort, alert user, do not proceed.
- Exit 0 → CLEARED: agent may proceed.

## HITL Gate
After **every** phase agent completes and BEFORE advancing to the next, the Orchestrator MUST execute:
```bash
source .env && bash .github/hooks/hitl-gate.sh <CompletedPhase> <NextPhase> <Deliverable>
```
- Exit 1 → REJECTED by human (interactive) — STOP pipeline, log rejection.
- Exit 0 → APPROVED (human confirmed or auto-approved in pipeline mode) — run pre-run hook for next agent.

## Inputs
- `requirements/requirement.txt` — Confluence URL
- Phase agent status reports
- `.env` — credentials and connection details (`INTERACTIVE_MODE`, `OFFLINE_MODE`, etc.)

## Outputs
- `agents/orchestrator/pipeline-log.md` — updated at every hook run, HITL gate decision, and phase transition
- Phase gate approval or rejection signals

## Phase Execution Order
| Order | Agent               | Pre-Run Hook | HITL Gate | Gate Condition                                      |
|-------|---------------------|:------------:|:---------:|-----------------------------------------------------|
| 1     | AnalysisAgent       | ✅           | ✅        | Confluence URL present in `requirements/requirement.txt` |
| 2     | RequirementsAgent   | ✅           | ✅        | AnalysisAgent → `STATUS: COMPLETE`                  |
| 3     | GapAnalysisAgent    | ✅           | ✅        | RequirementsAgent → `STATUS: COMPLETE` · Both `requirements-spec.md` and `jira-stories.md` exist |
| 4     | PlanningAgent       | ✅           | ✅        | GapAnalysisAgent → `STATUS: COMPLETE` (zero unresolved gaps) + GitLab reachable |
| 5     | DesignAgent         | ✅           | ✅        | PlanningAgent → `STATUS: COMPLETE`                  |
| 6     | DevelopmentAgent    | ✅           | ✅        | DesignAgent → `STATUS: COMPLETE` *(includes inline code review — produces `review/review-report.md`)* |
| 7     | TestingAgent        | ✅           | ✅        | DevelopmentAgent → `STATUS: COMPLETE` (FAIL count = 0 in review report) |
| 8     | DeploymentAgent     | ✅           | ✅        | TestingAgent → `STATUS: COMPLETE`                   |
| 9     | DocumentationAgent  | ✅           | ✅        | DeploymentAgent → `STATUS: COMPLETE`                |

