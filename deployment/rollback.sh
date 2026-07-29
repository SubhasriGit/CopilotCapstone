#!/bin/sh
# rollback.sh — Rolls back GIthubCopilotCapstone to the last known good deployment.
# No secrets in this script — all via environment variables.
#
# Usage: APP_ENV=production ROLLBACK_VERSION=<version> sh rollback.sh

set -e

echo "⏪ GIthubCopilotCapstone Rollback Script"
echo "   Environment    : ${APP_ENV:-local}"
echo "   Target Version : ${ROLLBACK_VERSION:-latest-stable}"
echo "   Timestamp      : $(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo ""
echo "⚠️  ROLLBACK INITIATED"
echo "   Reason: Smoke test failure or manual trigger"
echo ""

# ── OQ-005: Replace with actual rollback command for your deployment target ──
# Examples:
#
# AWS Elastic Beanstalk:
#   aws elasticbeanstalk update-environment \
#     --environment-name capstone-prod \
#     --version-label "$ROLLBACK_VERSION"
#
# Kubernetes:
#   kubectl rollout undo deployment/capstone-app -n production
#
# Docker / Docker Compose:
#   docker pull yourrepo/capstone:${ROLLBACK_VERSION}
#   docker-compose up -d
#
# On-prem systemd:
#   ssh deploy@host "systemctl stop capstone && \
#                    cp /opt/capstone/releases/${ROLLBACK_VERSION}.jar /opt/capstone/current.jar && \
#                    systemctl start capstone"

echo "   ── PLACEHOLDER: add rollback command when OQ-005 is resolved ──"
echo ""
echo "✅ Rollback script complete. Verify deployment health with:"
echo "   curl \$APP_URL/health"
