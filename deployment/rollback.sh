#!/bin/sh
# rollback.sh — Rolls back OfficeCheck to the previous Render deployment.
# All configuration is via environment variables — no secrets in this script.

set -eu

echo "⏪ OfficeCheck Rollback Script"
echo "   Timestamp : $(date -u +%Y-%m-%dT%H:%M:%SZ)"

require_env() {
  eval "value=\${$1-}"
  if [ -z "$value" ]; then
    echo "❌ Required environment variable '$1' is not set."
    exit 1
  fi
}

require_env "RENDER_API_KEY"
require_env "RENDER_SERVICE_ID"

response_file="deployment/render-deploys.json"
curl -fsS \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services/$RENDER_SERVICE_ID/deploys?limit=10" \
  -o "$response_file"

rollback_id=$(python -c "import json; data=json.load(open('$response_file')); items=data.get('items', data) if isinstance(data, dict) else data; items=items if isinstance(items, list) else [items]; ids=[]; [ids.append((item.get('deploy', item).get('id') or item.get('id'))) for item in items if (item.get('deploy', item).get('id') or item.get('id'))]; print(ids[1] if len(ids) > 1 else '')")
rm -f "$response_file"

if [ -z "$rollback_id" ]; then
  echo "❌ Could not determine previous Render deploy ID."
  exit 1
fi

curl -fsS -X POST \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services/$RENDER_SERVICE_ID/deploys/$rollback_id/rollback"

echo "✅ Rollback triggered for deploy $rollback_id"