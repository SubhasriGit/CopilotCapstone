# MCP Server Configuration — OfficeCheck

This folder contains the MCP (Model Context Protocol) server configuration for the OfficeCheck project.  
MCP servers expose external tools (Confluence, Jira, GitHub, GitLab) as callable functions to AI agents.

---

## Configured MCP Servers

| Server | Package | Handles | Protocol |
|--------|---------|---------|----------|
| `atlassian` | `mcp-atlassian` (Python/uvx) | Confluence + Jira | stdio |
| `github` | `@modelcontextprotocol/server-github` (Node/npx) | GitHub repos, issues, PRs | stdio |
| `gitlab` | `@modelcontextprotocol/server-gitlab` (Node/npx) | GitLab repos, wikis, milestones | stdio |
| `playwright` | `@playwright/mcp` (Node/npx) | Browser automation, UI testing | stdio |
| `selenium` | Selenium Grid JAR (Java) | Cross-browser automation | http |

---

## Prerequisites

### 1. Python + uv (for Atlassian MCP)
```bash
# Install uv (fast Python package runner)
pip install uv
# or on Windows:
winget install astral-sh.uv

# Test Atlassian MCP server
uvx mcp-atlassian --help
```

### 2. Node.js ≥ 18 (for GitHub, GitLab, Playwright MCP)
```bash
# Download from: https://nodejs.org
node --version   # must be ≥ 18
npx --version    # comes with Node

# Servers are auto-installed on first run via npx -y
```

### 3. Java 20 (for Selenium)
```bash
# Already installed for this project (Amazon Corretto 20)
# Download Selenium Server JAR:
# https://github.com/SeleniumHQ/selenium/releases
# Set: SELENIUM_SERVER_JAR=C:\path\to\selenium-server-4.x.jar
```

---

## Environment Variables Required

All values are read from `.env` — **never hardcoded**.  
Copy `.env.example` to `.env` and fill in the values.

### Atlassian (Confluence + Jira)
| Variable | Maps to MCP env | Description |
|----------|----------------|-------------|
| `CONFLUENCE_URL` | `CONFLUENCE_URL` | e.g. `https://yourcompany.atlassian.net` |
| `CONFLUENCE_EMAIL` | `CONFLUENCE_USERNAME` | Your Atlassian account email |
| `CONFLUENCE_API_TOKEN` | `CONFLUENCE_API_TOKEN` | Generate at: https://id.atlassian.com/manage-profile/security/api-tokens |
| `JIRA_URL` | `JIRA_URL` | e.g. `https://yourcompany.atlassian.net` |
| `JIRA_EMAIL` | `JIRA_USERNAME` | Your Atlassian account email |
| `JIRA_API_TOKEN` | `JIRA_API_TOKEN` | Same token as Confluence |
| `JIRA_PROJECT_KEY` | `JIRA_PROJECT_KEY` | e.g. `KAN` |

### GitHub
| Variable | Maps to MCP env | Description |
|----------|----------------|-------------|
| `GITHUB_TOKEN` | `GITHUB_PERSONAL_ACCESS_TOKEN` | Generate at: https://github.com/settings/tokens — scopes: `repo`, `read:org` |

### GitLab
| Variable | Maps to MCP env | Description |
|----------|----------------|-------------|
| `GITLAB_TOKEN` | `GITLAB_PERSONAL_ACCESS_TOKEN` | Generate at: GitLab → Settings → Access Tokens — scope: `api` |
| `GITLAB_URL` | used to build `GITLAB_API_URL` | e.g. `https://gitlab.com` |

### Selenium (optional)
| Variable | Description |
|----------|-------------|
| `SELENIUM_SERVER_JAR` | Full path to `selenium-server-4.x.jar` |

---

## How to Use with GitHub Copilot CLI

Add this config to your Copilot settings file:

**Windows:** `%APPDATA%\GitHub Copilot\mcp.json`  
**macOS/Linux:** `~/.config/github-copilot/mcp.json`

```jsonc
// Point to this file or copy its contents:
// C:\Users\<you>\IdeaProjects\GIthubCopilotCapstone\MCP\mcp-config.json
```

Or reference it in VS Code `.vscode/mcp.json`:
```json
{
  "inputs": [],
  "servers": {
    // paste contents of mcp-config.json here
  }
}
```

---

## Verifying MCP Servers

```bash
# Test Atlassian (Confluence + Jira)
uvx mcp-atlassian

# Test GitHub MCP
npx -y @modelcontextprotocol/server-github

# Test GitLab MCP
npx -y @modelcontextprotocol/server-gitlab

# Test Playwright MCP
npx -y @playwright/mcp@latest
```

Each should start and wait for MCP protocol input (stdio).  
In an MCP-enabled client (Copilot, Claude Desktop, etc.) they will appear as callable tools.

---

## MCP Tools Exposed Per Server

### `atlassian`
- `confluence_search` — search pages by text
- `confluence_get_page` — fetch page content by ID or title
- `jira_get_issue` — fetch a Jira issue
- `jira_create_issue` — create Epic/Story/Task
- `jira_search_issues` — JQL search
- `jira_update_issue` — update fields, status

### `github`
- `create_repository`, `search_repositories`
- `get_file_contents`, `create_or_update_file`
- `create_issue`, `list_issues`, `create_pull_request`
- `push_files`, `create_branch`

### `gitlab`
- `create_repository`, `get_file_contents`
- `create_or_update_file`, `push_files`
- `create_merge_request`, `list_merge_requests`
- `create_issue`, `list_issues`

### `playwright`
- `browser_navigate`, `browser_click`, `browser_fill`
- `browser_screenshot`, `browser_evaluate`
- `browser_wait_for_selector`
