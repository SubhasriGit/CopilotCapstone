#!/bin/sh
# deploy.sh — Deployment script for OfficeCheck on Render.
# All configuration is via environment variables — no secrets in this script.

set -eu

echo "🚀 OfficeCheck — Render Deployment Script"
echo "   Timestamp : $(date -u +%Y-%m-%dT%H:%M:%SZ)"

require_env() {
  eval "value=\${$1-}"
  if [ -z "$value" ]; then
    echo "❌ Required environment variable '$1' is not set."
    exit 1
  fi
}

require_env "RENDER_DEPLOY_HOOK_URL"

echo "🔍 Triggering Render deployment..."
response_file="deployment/render-deploy-response.json"
http_code=$(curl -sS -o "$response_file" -w '%{http_code}' -X POST "$RENDER_DEPLOY_HOOK_URL")
cat "$response_file"
rm -f "$response_file"

if [ "$http_code" != "200" ] && [ "$http_code" != "201" ]; then
  echo "❌ Render deploy trigger failed (HTTP $http_code)"
  exit 1
fi

echo "✅ Deploy triggered successfully."
echo "📋 Monitor: https://dashboard.render.com"
echo "🔎 Health check: ${RENDER_APP_URL:-https://officecheck-api.onrender.com}/health"