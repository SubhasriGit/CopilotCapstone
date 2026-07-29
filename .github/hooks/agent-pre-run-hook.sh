#!/usr/bin/env bash
# =============================================================================
# agent-pre-run-hook.sh
# Purpose : Run BEFORE every agent execution in the SDLC pipeline.
#           1. Scans tracked files for hardcoded secrets.
#           2. Validates required connections with retry (3 attempts).
# Usage   : source .env && bash .github/hooks/agent-pre-run-hook.sh <AGENT_NAME>
# Exit    : 0 = OK | 1 = BLOCKED (secrets) | 2 = BLOCKED (connection failure)
# =============================================================================

AGENT_NAME="${1:-UNKNOWN_AGENT}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="agents/orchestrator/pipeline-log.md"

MAX_RETRIES=3
RETRY_DELAYS=(5 10 20)

log() { echo "[$TIMESTAMP][$AGENT_NAME] $1"; }
log_to_file() {
  echo "| $TIMESTAMP | $AGENT_NAME | $1 |" >> "$LOG_FILE" 2>/dev/null || true
}

trim_crlf() {
  printf '%s' "$1" | tr -d '\r\n'
}

check_connection() {
  local label="$1"
  local url="$2"
  local header="$3"
  local attempt status delay

  for attempt in $(seq 1 "$MAX_RETRIES"); do
    if [ -n "$header" ]; then
      status=$(curl -s -o /dev/null -w "%{http_code}" -H "$header" "$url" --max-time 10 2>/dev/null || echo "000")
    else
      status=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10 2>/dev/null || echo "000")
    fi

    if [ "$status" = "200" ] || [ "$status" = "202" ]; then
      log "OK: $label reachable (HTTP $status) on attempt $attempt/$MAX_RETRIES"
      log_to_file "✅ $label connection OK (attempt $attempt)"
      return 0
    fi

    log "WARN: $label unreachable (HTTP $status) — attempt $attempt/$MAX_RETRIES"
    if [ "$attempt" -lt "$MAX_RETRIES" ]; then
      delay=${RETRY_DELAYS[$((attempt - 1))]}
      log "      Retrying in ${delay}s ..."
      sleep "$delay"
    fi
  done

  log "ERROR: $label unreachable after $MAX_RETRIES attempts"
  log_to_file "❌ $label connection FAILED after $MAX_RETRIES attempts"
  return 1
}

# ---------------------------------------------------------------------------
# STEP 1 — Secret scan
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
log "=== PRE-RUN HOOK: Connection Check (max $MAX_RETRIES attempts/service) ==="

if [ "${OFFLINE_MODE:-false}" = "true" ]; then
  log "WARNING: Connection check skipped (OFFLINE_MODE=true)"
  log_to_file "⚠️ Connection check SKIPPED by flag"
  exit 0
fi

CONNECTION_FAIL=0

# Confluence (required)
if [ -n "$CONFLUENCE_URL" ] && [ -n "$CONFLUENCE_EMAIL" ] && [ -n "$CONFLUENCE_API_TOKEN" ]; then
  CONF_EMAIL="$(trim_crlf "$CONFLUENCE_EMAIL")"
  CONF_TOKEN="$(trim_crlf "$CONFLUENCE_API_TOKEN")"
  ENCODED=$(printf '%s' "${CONF_EMAIL}:${CONF_TOKEN}" | base64 2>/dev/null | tr -d '\r\n')
  if [ -z "$ENCODED" ]; then
    ENCODED=$(python3 -c "import base64,os; e=os.environ.get('CONFLUENCE_EMAIL','').strip(); t=os.environ.get('CONFLUENCE_API_TOKEN','').strip(); print(base64.b64encode(f'{e}:{t}'.encode()).decode())" 2>/dev/null)
  fi
  if ! check_connection "Confluence" "${CONFLUENCE_URL%/}/wiki/rest/api/space" "Authorization: Basic $ENCODED"; then
    CONNECTION_FAIL=1
  fi
else
  log "WARNING: Confluence env vars not set — skipping Confluence check"
  log_to_file "⚠️ Confluence env vars missing — check skipped"
fi

# Jira (required for RequirementsAgent + GapAnalysisAgent)
if [ -n "$JIRA_URL" ] && [ -n "$JIRA_EMAIL" ] && [ -n "$JIRA_API_TOKEN" ]; then
  JIRA_EMAIL_CLEAN="$(trim_crlf "$JIRA_EMAIL")"
  JIRA_TOKEN_CLEAN="$(trim_crlf "$JIRA_API_TOKEN")"
  JIRA_ENCODED=$(printf '%s' "${JIRA_EMAIL_CLEAN}:${JIRA_TOKEN_CLEAN}" | base64 2>/dev/null | tr -d '\r\n')
  if [ -z "$JIRA_ENCODED" ]; then
    JIRA_ENCODED=$(python3 -c "import base64,os; e=os.environ.get('JIRA_EMAIL','').strip(); t=os.environ.get('JIRA_API_TOKEN','').strip(); print(base64.b64encode(f'{e}:{t}'.encode()).decode())" 2>/dev/null)
  fi
  if ! check_connection "Jira" "${JIRA_URL%/}/rest/api/3/myself" "Authorization: Basic $JIRA_ENCODED"; then
    if [ "$AGENT_NAME" = "RequirementsAgent" ] || [ "$AGENT_NAME" = "GapAnalysisAgent" ]; then
      CONNECTION_FAIL=1
    else
      log "WARNING: Jira unreachable — non-blocking for $AGENT_NAME."
    fi
  fi
else
  log "WARNING: Jira env vars not set — skipping Jira check"
fi

# GitHub (warning only)
if [ -n "$GITHUB_TOKEN" ]; then
  if ! check_connection "GitHub" "https://api.github.com/user" "Authorization: Bearer $GITHUB_TOKEN"; then
    log "WARNING: GitHub unreachable — non-blocking."
    log_to_file "⚠️ GitHub connection FAILED — non-blocking"
  fi
else
  log "WARNING: GITHUB_TOKEN not set — skipping GitHub check"
fi

# GitLab (required for PlanningAgent)
if [ -n "$GITLAB_TOKEN" ] && [ -n "$GITLAB_URL" ]; then
  if ! check_connection "GitLab" "${GITLAB_URL%/}/api/v4/user" "PRIVATE-TOKEN: $GITLAB_TOKEN"; then
    if [ "$AGENT_NAME" = "PlanningAgent" ]; then
      CONNECTION_FAIL=1
    else
      log "WARNING: GitLab unreachable — non-blocking for $AGENT_NAME."
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
  log "BLOCKED: Required connection(s) unavailable after $MAX_RETRIES attempts."
  log_to_file "❌ PRE-RUN HOOK BLOCKED — connection failure after retries"
  exit 2
fi

log "=== PRE-RUN HOOK PASSED — $AGENT_NAME is cleared to execute ==="
log_to_file "✅ PRE-RUN HOOK PASSED — $AGENT_NAME cleared"
exit 0
