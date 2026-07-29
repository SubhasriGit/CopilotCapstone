# Orchestrator Skills

| Skill | Definition |
|---|---|
| Phase Routing | Selects the next SDLC agent to run based on current pipeline state |
| Pre-Run Hook Enforcement | Executes `agent-pre-run-hook.sh` before every agent; blocks pipeline on exit code 1 or 2 |
| Secret Scan Gating | Halts pipeline if the pre-run hook detects hardcoded secrets in any artifact |
| Connection Validation Gating | Halts pipeline if required connections (Confluence, Jira, GitHub) are unreachable |
| Gate Enforcement | Prevents phase transitions until all deliverables for the current phase are complete |
| Status Aggregation | Collects and summarises phase status reports into the pipeline log |
| Confluence Integration | Reads the requirement URL and blocks on missing or invalid values |
| Self-Healing Trigger | Retries failed phase executions up to 3 times with exponential backoff |
| Pipeline Logging | Writes hook results and transition records to `agents/orchestrator/pipeline-log.md` |
| User Confirmation | Prompts the user before advancing each phase gate |
