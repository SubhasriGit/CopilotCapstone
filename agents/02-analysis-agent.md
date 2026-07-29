# Analysis Agent

## Runnable Role
Performs the Analysis phase using `prompts/02-analysis-prompt.md` and `skills/02-analysis-skill.md`.

## Pre-Run Hook (Mandatory)
The Orchestrator runs this BEFORE invoking AnalysisAgent:
```bash
source .env && bash .github/hooks/agent-pre-run-hook.sh AnalysisAgent
```
- Exit 1 → BLOCKED: hardcoded secret found
- Exit 2 → BLOCKED: Confluence unreachable
- Exit 0 → CLEARED: proceed

## Inputs
- `requirements/requirement.txt` — Confluence page URL
- Confluence REST API (`CONFLUENCE_API_TOKEN`, `CONFLUENCE_EMAIL`)

## Outputs
- `project-scoping/analysis.md` — full analysis with stakeholders, feasibility, scope, risks, open questions

## Execution Steps
1. Run pre-run hook (Orchestrator responsibility).
2. Read Confluence URL from `requirements/requirement.txt`.
3. Fetch page content via `GET $CONFLUENCE_URL/wiki/rest/api/content/<id>?expand=body.storage`.
4. Parse and extract: business problem, E2E flow, stakeholders, constraints.
5. Perform feasibility, scope, and risk analysis.
6. Resolve all open questions where possible; flag unresolved ones.
7. Write full analysis to `project-scoping/analysis.md`.
8. Report `STATUS: COMPLETE` or `STATUS: BLOCKED` to the Orchestrator.

## Last Run
| Field       | Value |
|-------------|-------|
| Date        | 2026-07-29 |
| Hook Result | ✅ PASSED |
| Status      | ✅ COMPLETE |
| Deliverable | `project-scoping/analysis.md` updated |

