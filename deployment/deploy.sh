#!/bin/sh
# deploy.sh — Deployment script for OfficeCheck on Render.
# All configuration is via environment variables — no secrets in this script.
#
# Usage (local trigger):
#   RENDER_DEPLOY_HOOK_URL=<from-render-dashboard> sh deployment/deploy.sh
#
# In CI/CD: deploy stage calls the Render Deploy Hook automatically.

set -e

echo "🚀 OfficeCheck — Render Deployment Script"
echo "   Timestamp : $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Validate required env vars
check_required() {
  if [ -z "$(eval echo \$$1)" ]; then
    echo "❌ Required environment variable '$1' is not set."
    exit 1
  fi
}

echo ""
echo "🔍 Validating Render configuration..."
check_required "RENDER_DEPLOY_HOOK_URL"
echo "✅ Render deploy hook configured."

# Trigger Render deploy
echo ""
echo "🚀 Triggering Render deployment..."
RESPONSE=$(curl -s -o /tmp/render-response.json -w "%{http_code}" \
  -X POST "$RENDER_DEPLOY_HOOK_URL")
echo "   Render response: HTTP $RESPONSE"

if [ "$RESPONSE" != "200" ] && [ "$RESPONSE" != "201" ]; then
  echo "❌ Render deploy trigger failed (HTTP $RESPONSE)"
  cat /tmp/render-response.json || true
  exit 1
fi

echo "✅ Deploy triggered successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Monitor deploy at: https://dashboard.render.com"
echo "   2. Service URL: https://officecheck-api.onrender.com"
echo "   3. Health check: https://officecheck-api.onrender.com/health"
echo ""
echo "⚠️  Note: Render free tier spins down after 15 min inactivity."
echo "   First request after spin-down takes ~30s (cold start)."

