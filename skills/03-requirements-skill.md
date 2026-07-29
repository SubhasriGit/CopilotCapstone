# Requirements Skills

| Skill | Definition |
|---|---|
| Jira Connection Check | Calls `GET $JIRA_URL/rest/api/3/myself`; blocks execution if auth fails |
| Confluence Fetch | Retrieves Confluence page body via REST API using env-var credentials |
| Requirement Extraction | Converts Confluence content into structured FRs and NFRs |
| Functional Decomposition | Breaks business flows into discrete, testable functional requirements |
| Non-Functional Decomposition | Captures security, reliability, performance, and quality requirements |
| Acceptance Criteria Writing | Makes each requirement testable and measurable |
| Traceability Mapping | Links requirements to Confluence source and downstream Jira issues |
| Jira Epic Creation | Creates one Epic per business capability via Jira REST API |
| Jira Story Creation | Creates one Story per FR with description and acceptance criteria; links to Epic |
| Jira Task Creation | Creates one Task per acceptance criterion; links to parent Story |
| Jira Issue Persistence | Writes all created issue keys and titles to `requirements/jira-stories.md` |
| Gap Detection | Compares requirement spec against Jira stories to find missing, orphan, or untraceable items |
| Gap Remediation | Creates Jira issues for any gaps found and documents in `requirements/gap-analysis.md` |
| Conflict Detection | Flags ambiguous or conflicting statements in the requirement spec |

