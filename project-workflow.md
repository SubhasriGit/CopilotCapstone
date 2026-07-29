# Project Workflow — OfficeCheck SDLC Pipeline

**Project:** OfficeCheck — Digital Visitor Sign-In & Lobby Manager
**Repository:** SubhasriGit/CopilotCapstone
**Last Updated:** 2026-07-29

---

## Table of Contents
1. [Overview](#overview)
2. [The Three Building Blocks](#the-three-building-blocks)
   - [Skill](#1--skill)
   - [Prompt](#2--prompt)
   - [Agent](#3--agent)
3. [How They Work Together](#how-they-work-together)
4. [Full Pipeline Execution Order](#full-pipeline-execution-order)
5. [Execution Modes — Interactive vs Pipeline](#execution-modes)
6. [HITL Gate](#hitl-gate)
7. [Pre-Run Hook](#pre-run-hook)
8. [File Naming Convention](#file-naming-convention)
9. [Directory Structure](#directory-structure)

---

## Overview

The OfficeCheck project implements a **multi-agent SDLC orchestration pipeline** using GitHub Copilot.
A single **OrchestratorAgent** coordinates 10 specialised phase agents — each responsible for one SDLC
phase — from Analysis through to Documentation.

Every agent is built from three files:

| File | Lives in | Role |
|---|---|---|
| `NN-phase-name.md` | `skills/` | What the agent **can do** (capability list) |
| `NN-phase-name.md` | `prompts/` | **How** to do it, step-by-step (SOP) |
| `NN-phase-name-agent.md` | `agents/` | **Who** the agent is — inputs, outputs, gate conditions |

---

## The Three Building Blocks

### 1. 📋 SKILL
> *"What this agent is capable of doing"*

A Skill file is the **capability list** — the individual atomic abilities an agent has. Think of it as
the agent's CV/résumé. Each row is one discrete ability the agent can invoke.

Skills are **reusable** — multiple agents can share a skill (e.g., `Jira Connection Check` is used by
both RequirementsAgent and GapAnalysisAgent).

Skills do **not** tell the agent *when* or *in what order* to use them — that is the Prompt's job.

**Example — `skills/03-requirements.md`:**
```
| Jira Connection Check    | Calls GET $JIRA_URL/rest/api/3/myself; blocks if auth fails       |
| Confluence Fetch         | Retrieves Confluence page body via REST API using env-var creds   |
| Requirement Extraction   | Converts Confluence content into structured FRs and NFRs          |
| Jira Epic Creation       | Creates one Epic per business capability via Jira REST API        |
| Jira Story Creation      | Creates one Story per FR with description and acceptance criteria |
| Gap Detection            | Compares requirement spec against Jira stories to find gaps       |
```

---

### 2. 💬 PROMPT
> *"The step-by-step job instructions for this run"*

A Prompt is the **operational instruction manual (SOP)** — it tells the agent exactly what to do,
in what order, with what inputs, and how to handle errors. It **orchestrates the skills**.

The Prompt is loaded at **runtime** and directly drives the agent's behaviour for that specific phase.
It defines error handling, retry behaviour, what to output, and how to report status back to the
Orchestrator.

**Example — `prompts/03-requirements.md`:**
```
Phase 1 — Pre-Run Validation
  → Check JIRA_URL, JIRA_EMAIL, JIRA_API_TOKEN are set in environment
  → GET $JIRA_URL/rest/api/3/myself → must return HTTP 200, else STOP

Phase 2 — Requirement Extraction
  → Read project-scoping/analysis.md for context
  → Fetch Confluence page using Basic auth
  → Extract FRs, NFRs, acceptance criteria
  → Write structured spec to requirements/requirements-spec.md

Phase 3 — Jira Story and Task Creation
  → POST one Epic per business capability
  → POST one Story per FR, linked to Epic
  → POST one Task per acceptance criterion, linked to Story

Phase 4 — Gap Detection
  → Compare spec vs Jira stories → document in requirements/gap-analysis.md
```

---

### 3. 🤖 AGENT
> *"The deployable unit that ties everything together"*

An Agent definition is the **runnable contract** — it declares the agent's identity, what it needs to
run (gate conditions, inputs), what it produces (deliverables), and how the Orchestrator must invoke it
(pre-run hook, HITL gate).

The Orchestrator reads the agent file to decide *when* to invoke it and *whether* all preconditions pass.

**Example — `agents/03-requirements-agent.md`:**
```
Pre-Run Hook   → bash agent-pre-run-hook.sh RequirementsAgent
Gate Condition → AnalysisAgent must be STATUS: COMPLETE first
Inputs         → analysis.md, Confluence API, Jira credentials
Uses           → prompts/03-requirements.md + skills/03-requirements.md
Outputs        → requirements-spec.md, jira-stories.md, gap-analysis.md
```

---

## How They Work Together

```
ORCHESTRATOR reads agents/03-requirements-agent.md
       │
       ├─ Checks gate condition: "Is AnalysisAgent COMPLETE?" ✅
       ├─ Runs: bash .github/hooks/agent-pre-run-hook.sh RequirementsAgent ✅
       ├─ Runs: bash .github/hooks/hitl-gate.sh (if INTERACTIVE_MODE=true) ✅
       │
       ▼
AGENT loads prompts/03-requirements.md  ←  step-by-step instructions (SOP)
           + skills/03-requirements.md  ←  available capabilities (CV)
       │
       ├─ Phase 1: invokes skill "Jira Connection Check"
       ├─ Phase 2: invokes skills "Confluence Fetch" + "Requirement Extraction"
       ├─ Phase 3: invokes skills "Jira Epic/Story/Task Creation"
       ├─ Phase 4: invokes skill "Gap Detection"
       │
       ▼
DELIVERABLES written to disk:
  → requirements/requirements-spec.md
  → requirements/jira-stories.md
  → requirements/gap-analysis.md
       │
       ▼
AGENT reports STATUS: COMPLETE to Orchestrator
       │
       ▼
ORCHESTRATOR logs to agents/orchestrator/pipeline-log.md
            → HITL gate (human approves or pipeline auto-advances)
            → moves to next agent: GapAnalysisAgent
```

---

## Summary Table

| | Skill | Prompt | Agent |
|---|---|---|---|
| **Analogy** | Employee's CV | Employee's SOP | Employee's contract |
| **Answers** | *"What can I do?"* | *"How do I do it, step by step?"* | *"Who am I, what do I need, what do I deliver?"* |
| **Granularity** | Atomic capability | Full workflow | Deployable unit |
| **Used by** | Referenced in Prompt | Loaded at runtime by Agent | Read by Orchestrator |
| **Reusable?** | ✅ Yes — across agents | ⚠️ Phase-specific | ❌ One per phase |
| **Defines** | Individual abilities | Execution order & error handling | Gate conditions & I/O contract |
| **Example** | `Jira Epic Creation` | Phase 3: POST one epic per capability | `RequirementsAgent` definition |

---

## Full Pipeline Execution Order

| Order | Agent | Prompt | Skills | Key Deliverable |
|---|---|---|---|---|
| 01 | OrchestratorAgent | `prompts/01-orchestrator.md` | `skills/01-orchestrator.md` | `agents/orchestrator/pipeline-log.md` |
| 02 | AnalysisAgent | `prompts/02-analysis.md` | `skills/02-analysis.md` | `project-scoping/analysis.md` |
| 03 | RequirementsAgent | `prompts/03-requirements.md` | `skills/03-requirements.md` | `requirements/requirements-spec.md` |
| 04 | GapAnalysisAgent | `prompts/04-gap-analysis.md` | `skills/04-gap-analysis.md` | `requirements/gap-analysis.md` |
| 05 | PlanningAgent | `prompts/05-planning.md` | `skills/05-planning.md` | `planning/project-plan.md` |
| 06 | DesignAgent | `prompts/06-design.md` | `skills/06-design.md` | `design/` (6 docs) |
| 07 | DevelopmentAgent | `prompts/07-development.md` | `skills/07-development.md` | `src/main/java/` |
| 08 | ReviewAgent | `prompts/08-review.md` | `skills/08-review.md` | `review/review-report.md` |
| 09 | TestingAgent | `prompts/09-testing.md` | `skills/09-testing.md` | `testing/test-report.md` |
| 10 | DeploymentAgent | `prompts/10-deployment.md` | `skills/10-deployment.md` | `deployment/deployment-log.md` |
| 11 | DocumentationAgent | `prompts/11-documentation.md` | `skills/11-documentation.md` | `README.md` + `docs/` |

> **Gate rule:** Each agent runs only after the previous phase reports `STATUS: COMPLETE`.
> GapAnalysisAgent (04) blocks PlanningAgent (05) until all requirement gaps are resolved.

---

## Execution Modes

Controlled by the `INTERACTIVE_MODE` variable in `.env`:

| Mode | `INTERACTIVE_MODE` | Behaviour |
|---|---|---|
| **Interactive** | `true` | HITL gate **pauses** at every phase transition and waits for human approval (y/n) |
| **Pipeline / CI** | `false` or unset | HITL gate **auto-approves** all transitions — no human input required |

Set in `.env` for local runs:
```
INTERACTIVE_MODE=true
```

Not set in `ci-cd.yml` — pipeline always auto-advances.

---

## HITL Gate

**File:** `.github/hooks/hitl-gate.sh`

Called by the Orchestrator **after every phase completes** and **before** the next phase starts.

```bash
bash .github/hooks/hitl-gate.sh <CompletedPhase> <NextPhase> <Deliverable>
```

**Interactive mode flow:**
```
Phase completes
      ↓
hitl-gate.sh prints:
  ╔══════════════════════════════════════════════╗
  ║  Completed Phase : Requirements              ║
  ║  Next Phase      : Gap Analysis              ║
  ║  Deliverable     : requirements-spec.md      ║
  ╚══════════════════════════════════════════════╝
  Approve transition to Gap Analysis? [y/n]: _

  y → exit 0 → Orchestrator proceeds
  n → exit 1 → Pipeline STOPS, logs rejection
```

**Pipeline mode flow:**
```
Phase completes → hitl-gate.sh → ✅ Auto-approved → Next agent runs
```

---

## Pre-Run Hook

**File:** `.github/hooks/agent-pre-run-hook.sh`

Called by the Orchestrator **before every agent runs**. Runs two checks:

```bash
source .env && bash .github/hooks/agent-pre-run-hook.sh <AgentName>
```

| Exit Code | Meaning | Action |
|---|---|---|
| `0` | ✅ All clear | Agent may proceed |
| `1` | ❌ Hardcoded secret detected | BLOCKED — abort, alert user |
| `2` | ❌ Required connection unavailable | BLOCKED — abort, alert user |

**Check 1 — Secret Scan:** Scans `src/`, `config/`, `agents/`, `prompts/`, `skills/` for patterns like
hardcoded passwords, API keys, tokens, and private keys.

**Check 2 — Connection Validation:** Tests reachability of:
- Confluence (required for all agents)
- Jira (blocks RequirementsAgent and GapAnalysisAgent)
- GitLab (blocks PlanningAgent)
- GitHub (warning only)

Skip flags for offline development:
```
OFFLINE_MODE=true       # skips connection validation
SKIP_SECRET_CHECK=true  # skips secret scan (use with caution)
```

---

## File Naming Convention

### Convention: `<phase-order>-<phase-name>.md`

| Folder | Pattern | Example |
|---|---|---|
| `prompts/` | `NN-phase-name.md` | `04-gap-analysis.md` |
| `skills/` | `NN-phase-name.md` | `04-gap-analysis.md` |
| `agents/` | `NN-phase-name-agent.md` | `11-gap-analysis-agent.md` |

- The **folder name** (`prompts/` vs `skills/`) identifies the file type — no suffix needed.
- The **phase order** (`NN`) matches the execution sequence in the pipeline.
- The **phase name** is kebab-case and matches the agent's logical name.

---

## Directory Structure

```
CopilotCapstone/
├── agents/                         # Agent definitions (who + contract)
│   ├── 01-orchestrator-agent.md
│   ├── 02-analysis-agent.md
│   ├── 03-requirements-agent.md
│   ├── 11-gap-analysis-agent.md    # Phase 04 in execution order
│   ├── 04-planning-agent.md
│   ├── 05-design-agent.md
│   ├── 06-development-agent.md
│   ├── 07-review-agent.md
│   ├── 08-testing-agent.md
│   ├── 09-deployment-agent.md
│   ├── 10-documentation-agent.md
│   ├── README.md
│   └── orchestrator/
│       └── pipeline-log.md         # Live execution log
│
├── prompts/                        # Step-by-step SOPs (how to execute)
│   ├── 01-orchestrator.md
│   ├── 02-analysis.md
│   ├── 03-requirements.md
│   ├── 04-gap-analysis.md
│   ├── 05-planning.md
│   ├── 06-design.md
│   ├── 07-development.md
│   ├── 08-review.md
│   ├── 09-testing.md
│   ├── 10-deployment.md
│   └── 11-documentation.md
│
├── skills/                         # Capability lists (what agents can do)
│   ├── 01-orchestrator.md
│   ├── 02-analysis.md
│   ├── 03-requirements.md
│   ├── 04-gap-analysis.md
│   ├── 05-planning.md
│   ├── 06-design.md
│   ├── 07-development.md
│   ├── 08-review.md
│   ├── 09-testing.md
│   ├── 10-deployment.md
│   └── 11-documentation.md
│
├── .github/
│   ├── hooks/
│   │   ├── agent-pre-run-hook.sh   # Secret scan + connection validation
│   │   ├── hitl-gate.sh            # Human-In-The-Loop phase gate
│   │   ├── pre-commit-secrets      # Blocks commits with hardcoded secrets
│   │   └── pre-commit-connect      # Validates connections on commit
│   └── workflows/
│       └── ci-cd.yml               # GitHub Actions CI/CD pipeline
│
├── requirements/
│   ├── requirement.txt             # Confluence URL (Orchestrator reads this)
│   ├── requirements-spec.md        # FRs + NFRs (RequirementsAgent output)
│   ├── jira-stories.md             # Jira issue key map (RequirementsAgent output)
│   └── gap-analysis.md             # Gap report + traceability (GapAnalysisAgent output)
│
├── project-scoping/
│   └── analysis.md                 # Business analysis (AnalysisAgent output)
├── planning/
│   └── project-plan.md             # WBS + milestones (PlanningAgent output)
├── design/                         # 6 design docs (DesignAgent output)
├── src/                            # Java 20 source code (DevelopmentAgent output)
├── review/
│   └── review-report.md            # Code review results (ReviewAgent output)
├── testing/
│   └── test-report.md              # 74/74 tests passed (TestingAgent output)
├── deployment/
│   └── deployment-log.md           # Deployment strategy (DeploymentAgent output)
├── docs/                           # Full docs (DocumentationAgent output)
│
├── .env                            # Local credentials + INTERACTIVE_MODE=true
├── .env.example                    # Template (committed — no real secrets)
└── project-workflow.md             # ← This file
```
