# load-env.ps1
# Loads .env file into the current PowerShell process environment
# so MCP servers can resolve ${VAR_NAME} values from mcp-config.json
#
# Usage:
#   . .\MCP\load-env.ps1          # dot-source to apply in current shell
#   . .\MCP\load-env.ps1 -Verbose # show each variable being loaded

[CmdletBinding()]
param(
  [string]$EnvFile = (Join-Path (Split-Path $PSScriptRoot) ".env")
)

if (-not (Test-Path $EnvFile)) {
  Write-Error "❌ .env file not found at: $EnvFile"
  Write-Host "   Copy .env.example to .env and fill in your values."
  return
}

$loaded = 0
$skipped = 0

Get-Content $EnvFile | ForEach-Object {
  $line = $_.Trim()
  # Skip blank lines and comments
  if ($line -eq "" -or $line.StartsWith("#")) { $skipped++; return }
  # Parse KEY=VALUE
  if ($line -match "^([A-Za-z_][A-Za-z0-9_]*)=(.*)$") {
    $key   = $matches[1]
    $value = $matches[2].Trim('"').Trim("'")
    [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
    Write-Verbose "  SET $key"
    $loaded++
  }
}

Write-Host "✅ Loaded $loaded env vars from $EnvFile"
