[CmdletBinding()]
param(
  [switch]$PipelineMode,
  [switch]$SkipEnvLoad
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $root '.env'

Write-Host ''
Write-Host '╔══════════════════════════════════════════════╗'
Write-Host '║   OfficeCheck — Orchestrator Launcher        ║'
Write-Host '╚══════════════════════════════════════════════╝'
Write-Host ''

if (-not $SkipEnvLoad) {
  & "$root\setup.ps1" -EnvOnly
}

if ($PipelineMode) {
  $env:INTERACTIVE_MODE = 'false'
  Write-Host '  ✅ Pipeline mode enabled (INTERACTIVE_MODE=false)'
} else {
  $env:INTERACTIVE_MODE = 'true'
  Write-Host '  ✅ Interactive mode enabled (INTERACTIVE_MODE=true)'
}

$gitBash = @(
  'C:\Program Files\Git\bin\bash.exe',
  'C:\Program Files\Git\usr\bin\bash.exe',
  'C:\Program Files (x86)\Git\bin\bash.exe'
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $gitBash) {
  throw 'Git Bash not found. Install Git for Windows to run the orchestrator launcher.'
}

Write-Host "  ✅ Using Git Bash: $gitBash"
Write-Host ''
Write-Host 'Running orchestrator pre-run hook...'
Write-Host ''

& $gitBash (Join-Path $root '.github\hooks\agent-pre-run-hook.sh') 'OrchestratorAgent'
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
  Write-Host ''
  Write-Host '✅ Orchestrator is cleared.'
  Write-Host '   Starting Copilot orchestrator session...'
  Write-Host ''

  $copilotCmd = Get-Command copilot -ErrorAction Stop
  $savedGithubToken = $env:GITHUB_TOKEN
  $savedGithubPat = $env:GITHUB_PERSONAL_ACCESS_TOKEN
  Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue
  Remove-Item Env:GITHUB_PERSONAL_ACCESS_TOKEN -ErrorAction SilentlyContinue

  $orchestratorPrompt = @"
You are the OfficeCheck Orchestrator.
Follow the repository instructions in:
- agents/01-orchestrator-agent.md
- prompts/01-orchestrator.md
- skills/01-orchestrator.md

Execute the full SDLC workflow end-to-end in this repository:
Analysis → Requirements → Gap Analysis → Planning → Design → Development → Review → Testing → Deployment → Documentation.

Before every phase:
1. Run the pre-run hook for that agent.
2. If the hook fails, stop and report the block.
3. If the hook passes, continue.

Between phases:
1. Run the HITL gate.
2. If interactive approval is rejected, follow the recovery choice.
3. If approved, advance to the next phase.

Keep the workflow interactive and do not stop after precheck.
"@

  try {
    & $copilotCmd.Source `
      --interactive $orchestratorPrompt `
      --mode interactive `
      --model auto `
      --allow-all-tools `
      --allow-all-paths `
      --allow-all-urls `
      --add-dir $root `
      --secret-env-vars 'CONFLUENCE_API_TOKEN,JIRA_API_TOKEN,GITHUB_TOKEN,GITLAB_TOKEN,GITLAB_PERSONAL_ACCESS_TOKEN,RENDER_DEPLOY_HOOK_URL,RENDER_API_KEY,DB_PASSWORD,EXTERNAL_API_KEY'
  }
  finally {
    if ($null -ne $savedGithubToken) { $env:GITHUB_TOKEN = $savedGithubToken } else { Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue }
    if ($null -ne $savedGithubPat) { $env:GITHUB_PERSONAL_ACCESS_TOKEN = $savedGithubPat } else { Remove-Item Env:GITHUB_PERSONAL_ACCESS_TOKEN -ErrorAction SilentlyContinue }
  }
  exit $LASTEXITCODE
}

if ($exitCode -eq 1) {
  Write-Host ''
  Write-Host '❌ Blocked by secret scan.'
  exit 1
}

if ($exitCode -eq 2) {
  Write-Host ''
  Write-Host '❌ Blocked by connection failure.'
  exit 2
}

Write-Host ''
Write-Host "Orchestrator hook exited with code $exitCode"
exit $exitCode
