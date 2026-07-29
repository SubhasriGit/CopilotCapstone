#!/bin/sh
# setup.sh — Installs pre-commit hooks for the GIthubCopilotCapstone project.
# Run this script once after cloning the repository.

set -e

echo "🚀 Setting up GIthubCopilotCapstone development environment..."

# Verify we're in the project root
if [ ! -d ".git" ]; then
    echo "❌ ERROR: Run this script from the project root (where .git is located)."
    exit 1
fi

# Copy hooks to .git/hooks/
echo "📎 Installing pre-commit hooks..."
cp .github/hooks/pre-commit-secrets .git/hooks/pre-commit-secrets
cp .github/hooks/pre-commit-connect  .git/hooks/pre-commit-connect
chmod +x .git/hooks/pre-commit-secrets
chmod +x .git/hooks/pre-commit-connect

# Create the combined pre-commit entry point
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
# Combined pre-commit hook — runs all project hooks in order

set -e

# 1. Secret detection
sh "$(git rev-parse --git-dir)/hooks/pre-commit-secrets"

# 2. Connection validation
sh "$(git rev-parse --git-dir)/hooks/pre-commit-connect"
HOOK

chmod +x .git/hooks/pre-commit

echo ""
echo "✅ Pre-commit hooks installed successfully!"
echo ""
echo "   Hooks installed:"
echo "   • pre-commit-secrets  — blocks commits with hardcoded secrets"
echo "   • pre-commit-connect  — validates required connections are reachable"
echo ""
echo "   Environment variables (set before running the app):"
echo "   • EXTERNAL_API_URL    — Base URL for external API"
echo "   • EXTERNAL_API_KEY    — API key for external service"
echo "   • DB_URL              — Database connection URL (optional: defaults to H2 in-memory)"
echo "   • DB_USERNAME         — Database username"
echo "   • DB_PASSWORD         — Database password"
echo "   • APP_PORT            — Application port (default: 8080)"
echo ""
echo "   Offline development:"
echo "   • OFFLINE_MODE=true   — skips connection validation hook"
echo "   • SKIP_SECRET_CHECK=true — skips secret scan (requires team lead approval)"
echo ""
