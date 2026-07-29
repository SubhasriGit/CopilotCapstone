# Gap Analysis Agent

## Runnable Role
Validates requirements completeness and coverage by comparing `requirements/requirements-spec.md` against
`requirements/jira-stories.md`. Identifies all gaps, creates Jira remediation issues, and generates a
full traceability matrix.  
Uses `prompts/04-gap-analysis.md` and `skills/04-gap-analysis.md`.

## Pre-Run Hook (Mandatory)
The Orchestrator runs this BEFORE invoking GapAnalysisAgent:
```bash
source .env && bash .github/hooks/agent-pre-run-hook.sh GapAnalysisAgent
```
The hook checks:
- No hardcoded secrets in any artifact
- Confluence is reachable (HTTP 200/202)
- Jira is reachable (HTTP 200) — **blocks** if Jira auth fails

## Trigger Condition
GapAnalysisAgent is invoked only after **RequirementsAgent reports `STATUS: COMPLETE`**.  
Orchestrator checks that both deliverables exist before invoking:
- `requirements/requirements-spec.md`
- `requirements/jira-stories.md`

## Inputs
| Input | Source |
|---|---|
| `requirements/requirements-spec.md` | RequirementsAgent output |
| `requirements/jira-stories.md` | RequirementsAgent output — Jira issue key mapping |
| `project-scoping/analysis.md` | AnalysisAgent output — original business scope |
| Jira REST API | Live Jira project for issue verification (`JIRA_URL`, `JIRA_API_TOKEN`, `JIRA_EMAIL`, `JIRA_PROJECT_KEY`) |
| Confluence page | Original requirements source — cross-check for missed content |

## Outputs
| Output | Path | Description |
|---|---|---|
| Gap Analysis Report | `requirements/gap-analysis.md` | Full gap analysis: summary counts, gap table, remediation log, traceability matrix |
| Jira Remediation Issues | Live Jira project | New stories/tasks created for every identified gap |

## Gap Categories Detected
| Category | Description |
|---|---|
| **G-REQ-MISSING** | Requirement in spec with no Jira Story linked |
| **G-STORY-ORPHAN** | Jira Story with no traceable requirement in spec |
| **G-AC-MISSING** | Acceptance criterion in a story with no Jira Task created |
| **G-NFR-MISSING** | NFR in spec not covered by any Jira Story |
| **G-CONFLUENCE-MISSED** | Content in Confluence source not captured in requirements spec |
| **G-SCOPE-CONFLICT** | Story or requirement conflicts with the defined project scope |

## Execution Steps
1. Run pre-run hook (Orchestrator responsibility).
2. Verify Jira connection: `GET $JIRA_URL/rest/api/3/myself` — block if not HTTP 200.
3. Parse `requirements/requirements-spec.md` — extract all FR and NFR IDs and their acceptance criteria.
4. Parse `requirements/jira-stories.md` — extract all Jira keys and their linked requirement IDs.
5. Fetch live Jira issues for the project — verify each key in jira-stories.md actually exists in Jira.
6. Fetch Confluence source page — compare original content against captured requirements.
7. **Run gap detection** across all 6 gap categories (see above).
8. For each gap found:
   - Assign a `GAP-NNN` ID
   - Log details: type, description, requirement ref, Jira key, recommended action
   - Create a Jira remediation issue (Story or Task) and record the new key
9. Build the **Traceability Matrix** — every FR/NFR mapped to Jira Epic → Story → Task.
10. Write the full report to `requirements/gap-analysis.md`.
11. Report `STATUS: COMPLETE` (or `STATUS: GAPS_FOUND` if unresolved gaps remain) to the Orchestrator.

## Status Reporting

```
AGENT      : GapAnalysisAgent
PHASE      : Gap Analysis
STATUS     : COMPLETE | GAPS_FOUND | BLOCKED
HOOK       : PASSED | FAILED
GAPS_FOUND : <count>
GAPS_RESOLVED: <count>
DELIVERABLE: requirements/gap-analysis.md
NEXT_PHASE : Planning
```

- `COMPLETE` — All gaps resolved (or zero gaps found). Safe to advance to Planning.
- `GAPS_FOUND` — Unresolved gaps exist. Orchestrator must alert user; HITL gate decision required.
- `BLOCKED` — Pre-run hook failed (secrets or connection issue).

## Last Run
| Field       | Value |
|-------------|-------|
| Date        | 2026-07-29 |
| Hook Result | ✅ PASSED |
| Status      | ✅ COMPLETE |
| Gaps Found  | 26 |
| Gaps Resolved | 26 |
| Unresolved  | 0 |
| Deliverable | `requirements/gap-analysis.md` |
