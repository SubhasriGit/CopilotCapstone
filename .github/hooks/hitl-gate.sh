#!/usr/bin/env bash
# =============================================================================
# hitl-gate.sh — Human-In-The-Loop Phase Gate
#
# Purpose : Called by the Orchestrator BEFORE advancing to the next SDLC phase.
#           - INTERACTIVE_MODE=true  → Pauses and waits for human approval.
#           - INTERACTIVE_MODE=false → Auto-approves (pipeline/CI mode).
#
# Usage   : bash .github/hooks/hitl-gate.sh <CURRENT_PHASE> <NEXT_PHASE> <DELIVERABLE>
#
# Exit codes:
#   0 = Approved          → Proceed to next phase
#   1 = Retry same phase  → Re-run CURRENT_PHASE (max 3 retries tracked by Orchestrator)
#   2 = Restart pipeline  → Re-run from Phase 1 (Analysis)
#   3 = Abort             → Stop pipeline entirely
# =============================================================================

CURRENT_PHASE="${1:-UNKNOWN}"
NEXT_PHASE="${2:-UNKNOWN}"
DELIVERABLE="${3:-N/A}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="agents/orchestrator/pipeline-log.md"

log() { echo "[$TIMESTAMP][HITLGate] $1"; }
log_to_file() {
  echo "| $TIMESTAMP | HITLGate | $CURRENT_PHASE → $NEXT_PHASE | $1 |" >> "$LOG_FILE" 2>/dev/null || true
}

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              SDLC PHASE GATE — OfficeCheck               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo "  Completed Phase : $CURRENT_PHASE"
echo "  Next Phase      : $NEXT_PHASE"
echo "  Deliverable     : $DELIVERABLE"
echo "  Timestamp       : $TIMESTAMP"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# MODE CHECK — Interactive vs Pipeline
# ─────────────────────────────────────────────────────────────────────────────
if [ "${INTERACTIVE_MODE:-false}" != "true" ]; then
  log "PIPELINE MODE — INTERACTIVE_MODE is not set or false. Auto-approving phase transition."
  log_to_file "✅ AUTO-APPROVED (pipeline mode) — $NEXT_PHASE cleared to start"
  echo "  ✅ [Pipeline Mode] Phase gate auto-approved — advancing to $NEXT_PHASE"
  echo ""
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# INTERACTIVE MODE — Prompt the human
# ─────────────────────────────────────────────────────────────────────────────
echo "  🔔 [Interactive Mode] Human approval required before advancing."
echo ""
echo "  Please review the deliverable:"
echo "    → $DELIVERABLE"
echo ""

# Verify the deliverable file/dir actually exists
if [ -e "$DELIVERABLE" ]; then
  echo "  ✅ Deliverable exists on disk."
else
  echo "  ⚠️  Deliverable path not found: $DELIVERABLE"
fi
echo ""

# ── Approval prompt ──────────────────────────────────────────────────────────
while true; do
  printf "  Approve transition to %-20s? [y/n]: " "$NEXT_PHASE"
  read -r DECISION </dev/tty

  case "$DECISION" in
    [Yy]|[Yy][Ee][Ss])
      log "APPROVED by human — advancing to $NEXT_PHASE."
      log_to_file "✅ HUMAN APPROVED — $NEXT_PHASE cleared to start"
      echo ""
      echo "  ✅ Approved — $NEXT_PHASE will now execute."
      echo ""
      exit 0
      ;;

    [Nn]|[Nn][Oo])
      # ── Rejection recovery menu ────────────────────────────────────────────
      echo ""
      echo "  ╔══════════════════════════════════════════════════════════╗"
      echo "  ║  ❌ Phase '$CURRENT_PHASE' was rejected.                 ║"
      echo "  ║  What would you like to do?                              ║"
      echo "  ╠══════════════════════════════════════════════════════════╣"
      echo "  ║  [1] Retry same phase    — re-run $CURRENT_PHASE         ║"
      echo "  ║  [2] Restart pipeline   — re-run from Phase 1 (Analysis) ║"
      echo "  ║  [3] Abort              — stop the pipeline entirely      ║"
      echo "  ╚══════════════════════════════════════════════════════════╝"
      echo ""

      while true; do
        printf "  Enter choice [1/2/3]: "
        read -r RECOVERY </dev/tty

        case "$RECOVERY" in
          1)
            log "RECOVERY: Retry same phase — re-running $CURRENT_PHASE."
            log_to_file "🔁 REJECTED → RETRY SAME PHASE ($CURRENT_PHASE)"
            echo ""
            echo "  🔁 Retrying phase: $CURRENT_PHASE ..."
            echo "     (Orchestrator will re-run the pre-run hook and agent)"
            echo ""
            exit 1
            ;;
          2)
            log "RECOVERY: Restart from beginning — re-running from Analysis."
            log_to_file "🔄 REJECTED → RESTART FROM BEGINNING (Analysis)"
            echo ""
            echo "  🔄 Restarting pipeline from Phase 1 (AnalysisAgent) ..."
            echo ""
            exit 2
            ;;
          3)
            log "RECOVERY: Abort — pipeline stopped by user."
            log_to_file "🛑 REJECTED → PIPELINE ABORTED by user"
            echo ""
            echo "  🛑 Pipeline aborted. No further phases will run."
            echo "     Review deliverable and re-invoke the Orchestrator when ready."
            echo ""
            exit 3
            ;;
          *)
            echo "  Please enter 1, 2, or 3."
            ;;
        esac
      done
      ;;

    *)
      echo "  Please enter 'y' to approve or 'n' to reject."
      ;;
  esac
done


CURRENT_PHASE="${1:-UNKNOWN}"
NEXT_PHASE="${2:-UNKNOWN}"
DELIVERABLE="${3:-N/A}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="agents/orchestrator/pipeline-log.md"

log() { echo "[$TIMESTAMP][HITLGate] $1"; }
log_to_file() {
  echo "| $TIMESTAMP | HITLGate | $CURRENT_PHASE → $NEXT_PHASE | $1 |" >> "$LOG_FILE" 2>/dev/null || true
}

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              SDLC PHASE GATE — OfficeCheck               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo "  Completed Phase : $CURRENT_PHASE"
echo "  Next Phase      : $NEXT_PHASE"
echo "  Deliverable     : $DELIVERABLE"
echo "  Timestamp       : $TIMESTAMP"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# MODE CHECK — Interactive vs Pipeline
# ─────────────────────────────────────────────────────────────────────────────
if [ "${INTERACTIVE_MODE:-false}" != "true" ]; then
  log "PIPELINE MODE — INTERACTIVE_MODE is not set or false. Auto-approving phase transition."
  log_to_file "✅ AUTO-APPROVED (pipeline mode) — $NEXT_PHASE cleared to start"
  echo "  ✅ [Pipeline Mode] Phase gate auto-approved — advancing to $NEXT_PHASE"
  echo ""
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# INTERACTIVE MODE — Prompt the human
# ─────────────────────────────────────────────────────────────────────────────
echo "  🔔 [Interactive Mode] Human approval required before advancing."
echo ""
echo "  Please review the deliverable:"
echo "    → $DELIVERABLE"
echo ""

# Verify the deliverable file/dir actually exists
if [ -e "$DELIVERABLE" ]; then
  echo "  ✅ Deliverable exists on disk."
else
  echo "  ⚠️  Deliverable path not found: $DELIVERABLE"
fi
echo ""

# Prompt for decision
while true; do
  printf "  Approve transition to %-20s? [y/n]: " "$NEXT_PHASE"
  read -r DECISION </dev/tty

  case "$DECISION" in
    [Yy]|[Yy][Ee][Ss])
      log "APPROVED by human — advancing to $NEXT_PHASE."
      log_to_file "✅ HUMAN APPROVED — $NEXT_PHASE cleared to start"
      echo ""
      echo "  ✅ Approved — $NEXT_PHASE will now execute."
      echo ""
      exit 0
      ;;
    [Nn]|[Nn][Oo])
      log "REJECTED by human — pipeline STOPPED at $CURRENT_PHASE → $NEXT_PHASE gate."
      log_to_file "❌ HUMAN REJECTED — pipeline stopped at $CURRENT_PHASE gate"
      echo ""
      echo "  ❌ Rejected — pipeline stopped. Fix issues with $CURRENT_PHASE before retrying."
      echo ""
      exit 1
      ;;
    *)
      echo "  Please enter 'y' to approve or 'n' to reject."
      ;;
  esac
done
