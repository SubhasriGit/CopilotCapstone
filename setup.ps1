# setup.ps1 — Windows setup script for OfficeCheck
# Run ONCE after cloning: .\setup.ps1
# Then run again any time you need to reload .env into your shell.

[CmdletBinding()]
param(
  [switch]$EnvOnly   # Only reload .env, skip hook installation
)

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗"
Write-Host "║  OfficeCheck — Windows Setup                 ║"
Write-Host "╚══════════════════════════════════════════════╝"
Write-Host ""

$root = Split-Path $PSScriptRoot -ErrorAction SilentlyContinue
if (-not $root) { $root = $PSScriptRoot }
if (-not $root) { $root = Get-Location }

# ── Step 1: Verify .env exists ──────────────────────────────
Write-Host "[1/4] Checking .env file..."
$envFile = Join-Path $root ".env"
if (-not (Test-Path $envFile)) {
  $example = Join-Path $root ".env.example"
  if (Test-Path $example) {
    Copy-Item $example $envFile
    Write-Host "  ⚠️  .env not found — copied from .env.example"
    Write-Host "  ✏️  Open .env and fill in your real values, then re-run this script."
    exit 0
  } else {
    Write-Host "  ❌ Neither .env nor .env.example found. Cannot continue."
    exit 1
  }
} else {
  Write-Host "  ✅ .env found"
}

# ── Step 2: Load .env into current shell ────────────────────
Write-Host ""
Write-Host "[2/4] Loading .env into shell environment..."
$loadScript = Join-Path $root "MCP\load-env.ps1"
if (Test-Path $loadScript) {
  . $loadScript -Verbose:$VerbosePreference
} else {
  # Inline fallback if load-env.ps1 is missing
  $loaded = 0
  Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    if ($line -match "^([A-Za-z_][A-Za-z0-9_]*)=(.*)$") {
      [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2].Trim('"').Trim("'"), "Process")
      $loaded++
    }
  }
  Write-Host "  ✅ Loaded $loaded env vars from .env"
}

if ($EnvOnly) {
  Write-Host ""
  Write-Host "✅ Environment loaded. Ready to run MCP servers."
  exit 0
}

# ── Step 3: Install pre-commit hooks ────────────────────────
Write-Host ""
Write-Host "[3/4] Installing pre-commit hooks..."
$gitDir = Join-Path $root ".git"
if (-not (Test-Path $gitDir)) {
  Write-Host "  ⚠️  .git not found — skipping hook installation (not a git repo root)"
} else {
  $hooksDir = Join-Path $gitDir "hooks"
  New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null

  $secretsHook  = Join-Path $root ".github\hooks\pre-commit-secrets"
  $connectHook  = Join-Path $root ".github\hooks\pre-commit-connect"
  $agentHook    = Join-Path $root ".github\hooks\agent-pre-run-hook.sh"

  foreach ($src in @($secretsHook, $connectHook, $agentHook)) {
    if (Test-Path $src) {
      $dest = Join-Path $hooksDir (Split-Path $src -Leaf)
      Copy-Item $src $dest -Force
      Write-Host "  ✅ Installed: $(Split-Path $src -Leaf)"
    }
  }

  # Combined pre-commit entry point (Git Bash compatible)
  $preCommit = Join-Path $hooksDir "pre-commit"
  @'
#!/bin/sh
# Combined pre-commit hook — auto-installed by setup.ps1
set -e
sh "$(git rev-parse --git-dir)/hooks/pre-commit-secrets"
sh "$(git rev-parse --git-dir)/hooks/pre-commit-connect"
'@ | Set-Content $preCommit -Encoding UTF8
  Write-Host "  ✅ Installed: pre-commit (combined)"
}

# ── Step 4: Verify MCP prerequisites ────────────────────────
Write-Host ""
Write-Host "[4/4] Checking MCP server prerequisites..."

$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
  $nodeVer = (node --version 2>&1)
  Write-Host "  ✅ Node.js $nodeVer — GitHub/GitLab/Playwright MCP ready"
} else {
  Write-Host "  ⚠️  Node.js not found — install from https://nodejs.org (≥ 18 required)"
  Write-Host "      Needed for: @modelcontextprotocol/server-github, server-gitlab, @playwright/mcp"
}

$uv = Get-Command uvx -ErrorAction SilentlyContinue
if ($uv) {
  Write-Host "  ✅ uvx found — Atlassian (Confluence + Jira) MCP ready"
} else {
  Write-Host "  ⚠️  uvx not found — install with: pip install uv"
  Write-Host "      Needed for: mcp-atlassian (Confluence + Jira)"
}

# ── Summary ─────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════════"
Write-Host "✅ Setup complete! Your environment is ready."
Write-Host ""
Write-Host "   To reload .env in a new terminal:  . .\setup.ps1 -EnvOnly"
Write-Host "   To run the app:                    mvn spring-boot:run"
Write-Host "   To run tests:                      mvn test"
Write-Host "   To trigger Render deploy:          sh deployment/deploy.sh"
Write-Host ""
