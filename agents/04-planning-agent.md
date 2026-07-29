# Planning Agent

## Runnable Role
Creates the project plan from analysis output, then publishes it to GitLab.  
Uses `prompts/05-planning.md` and `skills/05-planning.md`.

## Pre-Run Hook (Mandatory)
The Orchestrator runs this BEFORE invoking PlanningAgent:
```bash
source .env && bash .github/hooks/agent-pre-run-hook.sh PlanningAgent
```
The hook checks:
- No hardcoded secrets in any artifact
- Confluence is reachable
- **GitLab is reachable (HTTP 200) — BLOCKS if GitLab auth fails**
- `GITLAB_TOKEN`, `GITLAB_URL`, `GITLAB_PROJECT_ID` must all be set

## Trigger Condition
PlanningAgent is invoked **only after AnalysisAgent reports `STATUS: COMPLETE`**.  
Orchestrator checks `project-scoping/analysis.md` for the completion status before invoking.

## Inputs
- `requirements/requirements-spec.md`
- `project-scoping/analysis.md` — must have `STATUS: COMPLETE`
- `requirements/jira-stories.md` — Jira Epics/Stories for sprint alignment
- GitLab credentials from environment: `GITLAB_TOKEN`, `GITLAB_URL`, `GITLAB_PROJECT_ID`, `GITLAB_PROJECT_PATH`, `GITLAB_DEFAULT_BRANCH`

## Outputs
- `planning/project-plan.md` — local project plan (WBS, milestones, sprints, risks)
- **GitLab Wiki page** — plan published to `$GITLAB_URL/<project>/wikis/Project-Plan`
- **GitLab repository commit** — `planning/project-plan.md` committed to `$GITLAB_DEFAULT_BRANCH`
- **GitLab Milestones** — one milestone per SDLC phase created in the GitLab project

## Execution Steps
1. Run pre-run hook (Orchestrator responsibility).
2. Verify `project-scoping/analysis.md` has `STATUS: COMPLETE` — block if not.
3. Read requirements and analysis docs to build the plan.
4. Write plan to `planning/project-plan.md`.
5. **Verify GitLab connection**: `GET $GITLAB_URL/api/v4/user`
6. **Publish to GitLab Wiki**: `POST /api/v4/projects/:id/wikis` with plan content.
7. **Commit plan file to GitLab repo**: `POST /api/v4/projects/:id/repository/files/planning%2Fproject-plan.md`
8. **Create GitLab Milestones** for each SDLC phase with due dates.
9. Report `STATUS: COMPLETE` with GitLab URLs to Orchestrator.

## Last Run
| Field       | Value |
|-------------|-------|
| Status      | ⏳ Pending — awaiting GitLab credentials in `.env` |

