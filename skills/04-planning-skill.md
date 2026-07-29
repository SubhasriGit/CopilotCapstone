# Planning Skills

| Skill | Definition |
|---|---|
| Analysis Gate Check | Reads `project-scoping/analysis.md` and blocks if `STATUS` is not `COMPLETE` |
| GitLab Connection Check | Calls `GET $GITLAB_URL/api/v4/user`; blocks execution if auth fails |
| Work Breakdown Structure | Splits requirements into executable tasks aligned to Jira Epics |
| Sprint Planning | Groups Jira Stories into 2-week sprints with story point estimates |
| Timeline Estimation | Assigns effort estimates and target dates to tasks and milestones |
| Dependency Mapping | Identifies task order and blocking relationships |
| Milestone Definition | Defines one phase-gated milestone per SDLC phase |
| Resource Planning | Assigns ownership to work items |
| Risk Planning | Converts analysis risks into mitigation tasks with owners |
| GitLab Wiki Publish | Creates or updates a Wiki page via `POST/PUT /api/v4/projects/:id/wikis` |
| GitLab File Commit | Commits `planning/project-plan.md` to GitLab repo via Files API |
| GitLab Milestone Creation | Creates one GitLab Milestone per SDLC phase via Milestones API |
| Partial Success Reporting | Reports which GitLab publish steps succeeded and which failed without blocking local plan |

