# Orchestrator Agent

## Runnable Role
Coordinates all SDLC phase agents using `prompts/01-orchestrator-prompt.md`.  
Enforces pre-run hooks, phase gates, and pipeline logging.

## Pre-Run Hook
Before invoking **any** phase agent, the Orchestrator MUST execute:
```bash
source .env && bash .github/hooks/agent-pre-run-hook.sh <AgentName>
```
- Exit 1 → BLOCKED: hardcoded secret found — abort, alert user, do not proceed.
- Exit 2 → BLOCKED: required connection unavailable — abort, alert user, do not proceed.
- Exit 0 → CLEARED: agent may proceed.

## Inputs
- `requirements/requirement.txt` — Confluence URL
- Phase agent status reports
- `.env` — credentials and connection details

## Outputs
- `agents/orchestrator/pipeline-log.md` — updated at every hook run and phase transition
- Phase gate approval or rejection signals

## Phase Execution Order
| Order | Agent               | Pre-Run Hook Required | Gate Condition                                      |
|-------|---------------------|-----------------------|-----------------------------------------------------|
| 1     | AnalysisAgent       | ✅                    | Confluence URL present in `requirements/requirement.txt` |
| 2     | RequirementsAgent   | ✅ (checks Jira)      | AnalysisAgent → `STATUS: COMPLETE`                  |
| 3     | PlanningAgent       | ✅ (checks GitLab)    | AnalysisAgent → `STATUS: COMPLETE` + GitLab reachable |
| 4     | DesignAgent         | ✅                    | RequirementsAgent → `STATUS: COMPLETE`              |
| 5     | DevelopmentAgent    | ✅                    | DesignAgent → `STATUS: COMPLETE`                    |
| 6     | ReviewAgent         | ✅                    | DevelopmentAgent → `STATUS: COMPLETE`               |
| 7     | TestingAgent        | ✅                    | ReviewAgent → `STATUS: COMPLETE`                    |
| 8     | DeploymentAgent     | ✅                    | TestingAgent → `STATUS: COMPLETE`                   |
| 9     | DocumentationAgent  | ✅                    | DeploymentAgent → `STATUS: COMPLETE`                |

