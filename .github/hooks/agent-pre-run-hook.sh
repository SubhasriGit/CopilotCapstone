#!/usr/bin/env bash
# =============================================================================
# agent-pre-run-hook.sh
# Purpose : Run BEFORE every agent execution in the SDLC pipeline.
#           1. Scans all tracked source files for hardcoded secrets.
#           2. Validates that all required connections are reachable.
# Usage   : source .env && bash .github/hooks/agent-pre-run-hook.sh <AGENT_NAME>
# Exit    : 0 = OK, 1 = BLOCKED (secrets found), 2 = BLOCKED (connection failed)
# =============================================================================

AGENT_NAME="${1:-UNKNOWN_AGENT}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="agents/orchestrator/pipeline-log.md"

log() { echo "[$TIMESTAMP][$AGENT_NAME] $1"; }
log_to_file() {
  echo "| $TIMESTAMP | $AGENT_NAME | $1 |" >> "$LOG_FILE" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# STEP 1 — Secret / hardcoded credentials scan
# ---------------------------------------------------------------------------
log "=== PRE-RUN HOOK: Secret Scan ==="

if [ "${SKIP_SECRET_CHECK:-false}" = "true" ]; then
  log "WARNING: Secret scan skipped (SKIP_SECRET_CHECK=true)"
  log_to_file "⚠️ Secret scan SKIPPED by flag"
else
  SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]{4,}"
    "passwd\s*=\s*['\"][^'\"]{4,}"
    "api[_-]?key\s*=\s*['\"][^'\"]{8,}"
    "apikey\s*=\s*['\"][^'\"]{8,}"
    "secret\s*=\s*['\"][^'\"]{8,}"
    "token\s*=\s*['\"][^'\"]{8,}"
    "Authorization\s*:\s*Bearer\s+[A-Za-z0-9._-]{20,}"
    "-----BEGIN (RSA |EC )?PRIVATE KEY-----"
  )

  SCAN_DIRS=("src" "config" "scripts" "deployment" "agents" "prompts" "skills")
  FOUND=0

  for pattern in "${SECRET_PATTERNS[@]}"; do
    for dir in "${SCAN_DIRS[@]}"; do
      [ -d "$dir" ] || continue
      matches=$(grep -rEi --include="*.java" --include="*.properties" \
                          --include="*.yml" --include="*.yaml" \
                          --include="*.json" --include="*.sh" \
                          --include="*.md" \
                          "$pattern" "$dir" 2>/dev/null | \
                grep -v "System.getenv" | grep -v "getenv(" | \
                grep -v "replace-me" | grep -v "your-" | \
                grep -v "#" | grep -v "example")
      if [ -n "$matches" ]; then
        log "ERROR: Hardcoded secret detected (pattern: $pattern):"
        echo "$matches"
        FOUND=1
      fi
    done
  done

  if [ "$FOUND" -eq 1 ]; then
    log "BLOCKED: Remove hardcoded secrets before running agent $AGENT_NAME."
    log_to_file "❌ Secret scan FAILED — hardcoded credentials detected"
    exit 1
  fi

  log "OK: No hardcoded secrets found."
  log_to_file "✅ Secret scan PASSED"
fi

# ---------------------------------------------------------------------------
# STEP 2 — Connection validation
# ---------------------------------------------------------------------------
log "=== PRE-RUN HOOK: Connection Check ==="

if [ "${OFFLINE_MODE:-false}" = "true" ]; then
  log "WARNING: Connection check skipped (OFFLINE_MODE=true)"
  log_to_file "⚠️ Connection check SKIPPED by flag"
  exit 0
fi

CONNECTION_FAIL=0

# --- Confluence ---
if [ -n "$CONFLUENCE_URL" ] && [ -n "$CONFLUENCE_EMAIL" ] && [ -n "$CONFLUENCE_API_TOKEN" ]; then
  ENCODED=$(echo -n "${CONFLUENCE_EMAIL}:${CONFLUENCE_API_TOKEN}" | base64 2>/dev/null || \
            python3 -c "import base64,os; print(base64.b64encode(f\"{os.environ['CONFLUENCE_EMAIL']}:{os.environ['CONFLUENCE_API_TOKEN']}\".encode()).decode())" 2>/dev/null)
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Basic $ENCODED" \
    "${CONFLUENCE_URL%/}/wiki/rest/api/space" --max-time 10 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "202" ]; then
    log "OK: Confluence reachable (HTTP $STATUS)"
    log_to_file "✅ Confluence connection OK"
  else
    log "ERROR: Confluence not reachable (HTTP $STATUS)"
    log_to_file "❌ Confluence connection FAILED (HTTP $STATUS)"
    CONNECTION_FAIL=1
  fi
else
  log "WARNING: Confluence env vars not set — skipping Confluence check"
fi

# --- Jira ---
if [ -n "$JIRA_URL" ] && [ -n "$JIRA_EMAIL" ] && [ -n "$JIRA_API_TOKEN" ]; then
  JIRA_ENCODED=$(echo -n "${JIRA_EMAIL}:${JIRA_API_TOKEN}" | base64 2>/dev/null || \
                 python3 -c "import base64,os; print(base64.b64encode(f\"{os.environ['JIRA_EMAIL']}:{os.environ['JIRA_API_TOKEN']}\".encode()).decode())" 2>/dev/null)
  JIRA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Basic $JIRA_ENCODED" \
    "${JIRA_URL%/}/rest/api/3/myself" --max-time 10 2>/dev/null || echo "000")
  if [ "$JIRA_STATUS" = "200" ]; then
    log "OK: Jira reachable (HTTP $JIRA_STATUS)"
    log_to_file "✅ Jira connection OK"
  elif [ "$JIRA_STATUS" = "000" ] || [ -z "$JIRA_STATUS" ]; then
    log "WARNING: Jira unreachable — continuing (Jira may not be required for this agent)"
    log_to_file "⚠️ Jira connection UNREACHABLE — non-blocking for non-requirements agents"
  else
    log "ERROR: Jira auth failed (HTTP $JIRA_STATUS) — check JIRA_EMAIL and JIRA_API_TOKEN"
    log_to_file "❌ Jira connection FAILED (HTTP $JIRA_STATUS)"
    # Only block for requirements agent
    if [ "$AGENT_NAME" = "RequirementsAgent" ]; then
      CONNECTION_FAIL=1
    fi
  fi
else
  log "WARNING: Jira env vars not set — skipping Jira check"
fi

# --- GitHub ---
if [ -n "$GITHUB_TOKEN" ]; then
  GH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/user" --max-time 10 2>/dev/null || echo "000")
  if [ "$GH_STATUS" = "200" ]; then
    log "OK: GitHub reachable (HTTP $GH_STATUS)"
    log_to_file "✅ GitHub connection OK"
  else
    log "WARNING: GitHub not reachable (HTTP $GH_STATUS)"
    log_to_file "⚠️ GitHub connection FAILED (HTTP $GH_STATUS)"
  fi
else
  log "WARNING: GITHUB_TOKEN not set — skipping GitHub check"
fi

# --- GitLab ---
if [ -n "$GITLAB_TOKEN" ] && [ -n "$GITLAB_URL" ]; then
  GL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "${GITLAB_URL%/}/api/v4/user" --max-time 10 2>/dev/null || echo "000")
  if [ "$GL_STATUS" = "200" ]; then
    log "OK: GitLab reachable (HTTP $GL_STATUS)"
    log_to_file "✅ GitLab connection OK"
  elif [ "$GL_STATUS" = "000" ]; then
    log "WARNING: GitLab unreachable — non-blocking for non-planning agents"
    log_to_file "⚠️ GitLab connection UNREACHABLE — non-blocking"
  else
    log "ERROR: GitLab auth failed (HTTP $GL_STATUS) — check GITLAB_TOKEN"
    log_to_file "❌ GitLab connection FAILED (HTTP $GL_STATUS)"
    # Only block for planning agent
    if [ "$AGENT_NAME" = "PlanningAgent" ]; then
      CONNECTION_FAIL=1
    fi
  fi
else
  log "WARNING: GITLAB_TOKEN or GITLAB_URL not set — skipping GitLab check"
  if [ "$AGENT_NAME" = "PlanningAgent" ]; then
    log "ERROR: GitLab vars required for PlanningAgent (GITLAB_TOKEN, GITLAB_URL, GITLAB_PROJECT_ID)"
    log_to_file "❌ GitLab vars missing — PlanningAgent BLOCKED"
    CONNECTION_FAIL=1
  fi
fi

if [ "$CONNECTION_FAIL" -eq 1 ]; then
  log "BLOCKED: Required connection(s) unavailable. Fix connectivity before running $AGENT_NAME."
  log_to_file "❌ PRE-RUN HOOK BLOCKED — connection failure"
  exit 2
fi

log "=== PRE-RUN HOOK PASSED — $AGENT_NAME is cleared to execute ==="
log_to_file "✅ PRE-RUN HOOK PASSED — $AGENT_NAME cleared"
exit 0
