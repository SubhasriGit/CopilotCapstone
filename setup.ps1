# setup.ps1 — Windows setup script for OfficeCheck
# Run ONCE after cloning: .\setup.ps1
# Then run again any time you need to reload .env into your shell.

[CmdletBinding()]
param(
  [switch]$EnvOnly,       # Only reload .env, skip hook installation
  [switch]$Persist,       # Add auto-loader to PowerShell profile (run once)
  [switch]$RemoveProfile  # Remove auto-loader from PowerShell profile
)

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗"
Write-Host "║  OfficeCheck — Windows Setup                 ║"
Write-Host "╚══════════════════════════════════════════════╝"
Write-Host ""

$root = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
# If setup.ps1 is inside a subfolder, go up to project root
if (-not (Test-Path (Join-Path $root ".env")) -and (Test-Path (Join-Path $root "..\.env"))) {
  $root = Resolve-Path (Join-Path $root "..")
}
if (-not (Test-Path (Join-Path $root ".env")) -and -not (Test-Path (Join-Path $root ".env.example"))) {
  $root = Get-Location
}

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
  . $loadScript -EnvFile $envFile -Verbose:$VerbosePreference
} else {
  # Inline fallback if load-env.ps1 is missing
  $loaded = 0
  Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    if ($line -match "^([A-Za-z_][A-Za-z0-9_]*)=(.*)$") {
      $k = $matches[1]; $v = $matches[2].Trim('"').Trim("'")
      [System.Environment]::SetEnvironmentVariable($k, $v, "Process")
      $loaded++
    }
  }
  Write-Host "  ✅ Loaded $loaded env vars from .env"
}

# Ensure "bash" resolves to Git Bash on Windows (not WSL bash.exe)
$gitBashCandidates = @(
  "C:\Program Files\Git\bin\bash.exe",
  "C:\Program Files\Git\usr\bin\bash.exe",
  "C:\Program Files (x86)\Git\bin\bash.exe"
)
$gitBash = $gitBashCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($gitBash) {
  Set-Alias -Name bash -Value $gitBash -Scope Global
  Write-Host "  ✅ Using Git Bash: $gitBash"
} else {
  Write-Host "  ⚠️  Git Bash not found. Install Git for Windows to run .sh hooks."
}

# ── MCP variable aliases (always runs after .env is loaded) ──
# MCP servers expect specific names that differ from our .env keys.
$mappings = @{
  "GITLAB_PERSONAL_ACCESS_TOKEN" = $env:GITLAB_TOKEN
  "GITHUB_PERSONAL_ACCESS_TOKEN" = $env:GITHUB_TOKEN
  "GITLAB_API_URL"               = "$($env:GITLAB_URL)/api/v4"
  "CONFLUENCE_USERNAME"          = $env:CONFLUENCE_EMAIL
  "JIRA_USERNAME"                = $env:JIRA_EMAIL
}
foreach ($key in $mappings.Keys) {
  if ($mappings[$key]) {
    [System.Environment]::SetEnvironmentVariable($key, $mappings[$key], "Process")
    Write-Verbose "  ALIAS $key"
  }
}
Write-Host "  ✅ MCP aliases set (GITLAB_PERSONAL_ACCESS_TOKEN, GITHUB_PERSONAL_ACCESS_TOKEN, etc.)"

# ── Persist to PowerShell profile (optional, run once) ──────
$profileMarker  = "# OfficeCheck MCP env loader"
$profileCommand = ". `"$root\setup.ps1`" -EnvOnly"

if ($RemoveProfile) {
  if (Test-Path $PROFILE) {
    $content = Get-Content $PROFILE -Raw
    $cleaned = $content -replace "(?m)^$profileMarker\r?\n.*\r?\n?", ""
    Set-Content $PROFILE $cleaned.TrimEnd()
    Write-Host "  ✅ Removed auto-loader from PowerShell profile"
  }
  return
}

if ($Persist) {
  Write-Host ""
  Write-Host "[+] Adding auto-loader to PowerShell profile..."
  if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
  }
  $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
  if ($profileContent -notmatch [regex]::Escape($profileMarker)) {
    Add-Content $PROFILE "`n$profileMarker`n$profileCommand"
    Write-Host "  ✅ Added to: $PROFILE"
    Write-Host "  ℹ️  Every new PowerShell terminal will now auto-load .env and MCP aliases."
  } else {
    Write-Host "  ✅ Already in profile (no change needed)"
  }
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
  $preCommitBody = @(
    '#!/bin/sh'
    '# Combined pre-commit hook - auto-installed by setup.ps1'
    'set -e'
    'sh "$(git rev-parse --git-dir)/hooks/pre-commit-secrets"'
    'sh "$(git rev-parse --git-dir)/hooks/pre-commit-connect"'
  )
  Set-Content -Path $preCommit -Value $preCommitBody -Encoding UTF8
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
Write-Host "   To reload .env in a new terminal:            . .\setup.ps1 -EnvOnly"
Write-Host "   To auto-load in every new terminal (once):  . .\setup.ps1 -Persist"
Write-Host "   To remove auto-load from profile:           . .\setup.ps1 -RemoveProfile"
Write-Host "   To run the app:                    mvn spring-boot:run"
Write-Host "   To run tests:                      mvn test"
Write-Host "   To trigger Render deploy:          sh deployment/deploy.sh"
Write-Host ""

