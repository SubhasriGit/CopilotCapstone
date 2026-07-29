#!/bin/sh
# setup.sh — Sets up OfficeCheck development environment (Mac/Linux).
# Run ONCE after cloning: sh setup.sh
# Then run again any time to reload .env: sh setup.sh --env-only

set -e

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  OfficeCheck — Dev Environment Setup         ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── Step 1: Verify .env exists ──────────────────────────────
echo "[1/4] Checking .env file..."
if [ ! -f ".env" ]; then
  if [ -f ".env.example" ]; then
    cp .env.example .env
    echo "  ⚠️  .env not found — copied from .env.example"
    echo "  ✏️  Open .env and fill in your real values, then re-run this script."
    exit 0
  else
    echo "  ❌ Neither .env nor .env.example found."
    exit 1
  fi
fi
echo "  ✅ .env found"

# ── Step 2: Load .env into shell environment ────────────────
echo ""
echo "[2/4] Loading .env into shell environment..."
set -a
. ./.env
set +a
echo "  ✅ .env loaded — MCP servers will resolve variables correctly"

if [ "$1" = "--env-only" ]; then
  echo ""
  echo "✅ Environment loaded. Ready to run MCP servers."
  exit 0
fi

# ── Step 3: Install pre-commit hooks ────────────────────────
echo ""
echo "[3/4] Installing pre-commit hooks..."
if [ ! -d ".git" ]; then
  echo "  ⚠️  .git not found — skipping (not a git repo root)"
else
  mkdir -p .git/hooks
  cp .github/hooks/pre-commit-secrets .git/hooks/pre-commit-secrets
  cp .github/hooks/pre-commit-connect  .git/hooks/pre-commit-connect
  cp .github/hooks/agent-pre-run-hook.sh .git/hooks/agent-pre-run-hook.sh
  chmod +x .git/hooks/pre-commit-secrets
  chmod +x .git/hooks/pre-commit-connect
  chmod +x .git/hooks/agent-pre-run-hook.sh

  cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
set -e
sh "$(git rev-parse --git-dir)/hooks/pre-commit-secrets"
sh "$(git rev-parse --git-dir)/hooks/pre-commit-connect"
HOOK
  chmod +x .git/hooks/pre-commit
  echo "  ✅ pre-commit-secrets, pre-commit-connect, agent-pre-run-hook installed"
fi

# ── Step 4: Check MCP prerequisites ─────────────────────────
echo ""
echo "[4/4] Checking MCP server prerequisites..."

if command -v node >/dev/null 2>&1; then
  echo "  ✅ Node.js $(node --version) — GitHub/GitLab/Playwright MCP ready"
else
  echo "  ⚠️  Node.js not found — install from https://nodejs.org (≥18 required)"
fi

if command -v uvx >/dev/null 2>&1; then
  echo "  ✅ uvx found — Atlassian (Confluence + Jira) MCP ready"
else
  echo "  ⚠️  uvx not found — install with: pip install uv"
fi

# ── Summary ─────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════"
echo "✅ Setup complete!"
echo ""
echo "   Reload .env in a new terminal : sh setup.sh --env-only"
echo "   Run the app                   : mvn spring-boot:run"
echo "   Run tests                     : mvn test"
echo "   Trigger Render deploy         : sh deployment/deploy.sh"
echo ""

