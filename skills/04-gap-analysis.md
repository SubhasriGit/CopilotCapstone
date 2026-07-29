# Gap Analysis Skills

| Skill | Definition |
|---|---|
| Jira Connection Check | Calls `GET $JIRA_URL/rest/api/3/myself`; blocks if auth fails |
| Requirements Spec Parser | Extracts all FR/NFR IDs, titles, priorities, acceptance criteria from requirements-spec.md |
| Jira Story Map Parser | Builds `{ requirement_id → [jira_keys] }` map from jira-stories.md |
| Live Jira Issue Fetcher | `GET $JIRA_URL/rest/api/3/search?jql=project=<KEY>` — retrieves all live issues with type, status, parent |
| Confluence Content Fetcher | Re-fetches Confluence source via REST API; extracts all headings/bullets as checklist |
| G-REQ-MISSING Detection | Flags FRs/NFRs in spec with no linked Jira Story |
| G-STORY-ORPHAN Detection | Flags Jira Stories with no traceable requirement in spec |
| G-AC-MISSING Detection | Flags acceptance criteria with no corresponding Jira Task |
| G-NFR-MISSING Detection | Flags NFRs covered by zero Jira Stories |
| G-CONFLUENCE-MISSED Detection | Flags Confluence content not captured in requirements spec |
| G-SCOPE-CONFLICT Detection | Flags Jira Stories conflicting with out-of-scope items in analysis.md |
| Gap ID Assignment | Assigns sequential GAP-NNN identifiers to each detected gap |
| Jira Story Creator | Creates remediation Story for G-REQ-MISSING and G-CONFLUENCE-MISSED gaps |
| Jira Task Creator | Creates remediation Task under parent Story for G-AC-MISSING gaps |
| Jira Comment Writer | Adds triage comment to issue for G-STORY-ORPHAN and G-SCOPE-CONFLICT gaps |
| Traceability Matrix Builder | Assembles FR/NFR → Epic → Story → Task matrix with coverage status |
| Gap Report Writer | Writes full gap analysis report to `requirements/gap-analysis.md` |
| Coverage Scorer | Calculates `(FRs with full coverage / total FRs) x 100%` |
| Self-Healing Retry | Wraps all API calls with exponential backoff retry (3 attempts: 1s, 2s, 4s) |
| Orchestrator Status Reporter | Emits structured AGENT/PHASE/STATUS/GAPS_FOUND/GAPS_RESOLVED block |
