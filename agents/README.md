# SDLC Agents Index

This folder contains the **runnable agent definitions** for the end-to-end SDLC pipeline.
The instruction text lives in `prompts/`.
The skill definitions live in `skills/` as ordered flat files.

## Layout

| Agent | Runnable Definition | Prompt | Skills |
|---|---|---|---|
| OrchestratorAgent | `01-orchestrator-agent.md` | `prompts/01-orchestrator.md` | `skills/01-orchestrator.md` |
| AnalysisAgent | `02-analysis-agent.md` | `prompts/02-analysis.md` | `skills/02-analysis.md` |
| RequirementsAgent | `03-requirements-agent.md` | `prompts/03-requirements.md` | `skills/03-requirements.md` |
| GapAnalysisAgent | `11-gap-analysis-agent.md` | `prompts/04-gap-analysis.md` | `skills/04-gap-analysis.md` |
| PlanningAgent | `04-planning-agent.md` | `prompts/05-planning.md` | `skills/05-planning.md` |
| DesignAgent | `05-design-agent.md` | `prompts/06-design.md` | `skills/06-design.md` |
| DevelopmentAgent *(includes inline review)* | `06-development-agent.md` | `prompts/07-development.md` | `skills/07-development.md` |
| TestingAgent | `07-testing-agent.md` | `prompts/08-testing.md` | `skills/08-testing.md` |
| DeploymentAgent | `08-deployment-agent.md` | `prompts/09-deployment.md` | `skills/09-deployment.md` |
| DocumentationAgent | `09-documentation-agent.md` | `prompts/10-documentation.md` | `skills/10-documentation.md` |

## Cross-Cutting Rules
1. No hardcoded secrets.
2. Validate connections.
3. Use self-healing for external calls.
4. Require gate approval before phase transitions.
5. Require user confirmation before advancing.

## Pipeline Log
- `agents/orchestrator/pipeline-log.md`
