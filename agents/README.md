# SDLC Agents Index

This folder contains the **runnable agent definitions** for the end-to-end SDLC pipeline.
The instruction text lives in `prompts/`.
The skill definitions live in `skills/` as ordered flat files.

## Layout

| Agent | Runnable Definition | Prompt | Skills |
|---|---|---|---|
| OrchestratorAgent | `01-orchestrator-agent.md` | `01-orchestrator-prompt.md` | `skills/01-orchestrator-skill.md` |
| AnalysisAgent | `02-analysis-agent.md` | `02-analysis-prompt.md` | `skills/02-analysis-skill.md` |
| RequirementsAgent | `03-requirements-agent.md` | `03-requirements-prompt.md` | `skills/03-requirements-skill.md` |
| PlanningAgent | `04-planning-agent.md` | `04-planning-prompt.md` | `skills/04-planning-skill.md` |
| DesignAgent | `05-design-agent.md` | `05-design-prompt.md` | `skills/05-design-skill.md` |
| DevelopmentAgent | `06-development-agent.md` | `06-development-prompt.md` | `skills/06-development-skill.md` |
| ReviewAgent | `07-review-agent.md` | `07-review-prompt.md` | `skills/07-review-skill.md` |
| TestingAgent | `08-testing-agent.md` | `08-testing-prompt.md` | `skills/08-testing-skill.md` |
| DeploymentAgent | `09-deployment-agent.md` | `09-deployment-prompt.md` | `skills/09-deployment-skill.md` |
| DocumentationAgent | `10-documentation-agent.md` | `10-documentation-prompt.md` | `skills/10-documentation-skill.md` |

## Cross-Cutting Rules
1. No hardcoded secrets.
2. Validate connections.
3. Use self-healing for external calls.
4. Require gate approval before phase transitions.
5. Require user confirmation before advancing.

## Pipeline Log
- `agents/orchestrator/pipeline-log.md`
