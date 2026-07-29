# Requirements Agent

## Runnable Role
Extracts requirements from Confluence, creates Jira epics/stories/tasks, and detects gaps.  
Uses `prompts/03-requirements-prompt.md` and `skills/03-requirements-skill.md`.

## Pre-Run Hook (Mandatory)
The Orchestrator runs this BEFORE invoking RequirementsAgent:
```bash
source .env && bash .github/hooks/agent-pre-run-hook.sh RequirementsAgent
```
The hook checks:
- No hardcoded secrets in any artifact
- Confluence is reachable (HTTP 200/202)
- Jira is reachable (HTTP 200) — **blocks** if Jira auth fails

## Inputs
- `project-scoping/analysis.md`
- Confluence page content (fetched via REST API using `CONFLUENCE_API_TOKEN`)
- `JIRA_URL`, `JIRA_API_TOKEN`, `JIRA_EMAIL`, `JIRA_PROJECT_KEY` from environment

## Outputs
- `requirements/requirements-spec.md` — structured requirements (FRs, NFRs, traceability)
- `requirements/jira-stories.md` — mapping of each requirement to Jira issue keys
- `requirements/gap-analysis.md` — gaps found between Confluence content and created stories
- Jira issues created in the configured project (epics → stories → tasks)

## Execution Steps
1. Run pre-run hook (done by Orchestrator).
2. Verify Jira connection: `GET $JIRA_URL/rest/api/3/myself`.
3. Fetch Confluence page content.
4. Extract and document all requirements into `requirements/requirements-spec.md`.
5. Create Jira Epic per business domain, Stories per functional requirement, Tasks per acceptance criterion.
6. Write Jira issue keys to `requirements/jira-stories.md`.
7. Perform gap analysis — compare requirements vs created stories. Document in `requirements/gap-analysis.md`.
8. Update any gaps as new Jira issues or sub-tasks.

