## CRITICAL: NEVER USE "Kill Bash" or "Kill shell". ASK THE USER FOR PERMISSION WHEN YOU WANT TO KILL A PROCESS OR SHELL

## Best Practices

- Refer to https://www.anthropic.com/engineering/claude-code-best-practices for comprehensive guidance on using Claude Code effectively
- Always review and incorporate workflow improvement recommendations when working with Claude Code
- Continuously monitor the Claude Code best practices URL for updates and new recommendations to optimize development workflows

## Implementation Approach

- Bias towards research first - look up documentation, read existing code, and understand patterns before trial-and-error (this includes researching how to set up automated feedback loops)
- Bias towards automated feedback loops - think of ways to verify your own work (tests, Playwright, linters, running code) rather than asking the user to check
- When automated verification isn't feasible, discuss options with the user

## Git Commits

- NEVER include Claude references in commit messages (no "Generated with Claude Code" or "Co-Authored-By: Claude")
- Keep commit messages clean and professional without AI attribution

## MCP Server Recommendations

**MCP Servers (if available):**
- **Notion**: Provides CRUD capabilities for notion.so to create pages, databases, search workspace content (tailored to specific pages in my personal notion workspace)
- **GitHub**: Provides CRUD capabilities for github.com like repository management, issues, PRs, code search (tailored to public repositories and if needed personal repositories - ask for additional permissions if needed)
- **Playwright**: Provides browser automation capabilities using Playwright and enables LLMs to interact with web pages through structured accessibility snapshots, bypassing the need for screenshots or visually-tuned models.
- **PostHog**: Provides CRUD capabilities to posthog.com for analytics queries, feature flags, insights, and dashboard creation (tailored to my personal PostHog instance)
- **Context7**: Retrieve up-to-date library documentation
- **Exa AI**: Web search, Exa Webset search, company research, deep research tasks
- **Dovetail**: User research data and insights (tailored to my personal Dovetail account)
- **DeepWiki**: Public GitHub repository documentation and insights. Has a Graph RAG like understanding of public GitHub repositories
- **Ragie**: Knowledge base search and retrieval RAG style (tailored to my personal Ragie instance)

**Usage Guidelines:**
- Use Context7 for library documentation instead of guessing API usage
- Use DeepWiki for understanding public GitHub repository code
- Use GitHub MCP for comprehensive repository operations
- Utilize Notion for searching for web information in my personal tailored database. As it is a CRUD and not RAG MCP server, this is less ideal but can be worth a shot.
- Use Exa AI for research tasks requiring current web information

## npm Usage

- NEVER use `npm install` - always use `npm ci` instead
- `npm ci` provides clean, reproducible installs from package-lock.json
- `npm ci` is faster and more reliable for development and CI/CD

## Docker / Podman Containers

- ALWAYS run containers in detached mode: `docker-compose up -d` or `podman-compose up -d`
- NEVER run without `-d` flag - dev servers block indefinitely
- Use `docker-compose logs -f` or `podman-compose logs -f` to view logs after starting
- When a `compose.yaml` or `docker-compose.yml` exists, check it for the configured port before starting
- For Node.js projects: node_modules should be in an anonymous volume (`/app/node_modules`) to isolate from host
- Refresh dependencies with: `[docker|podman]-compose down -v && [docker|podman]-compose up -d`

### Tailnet-First Port Binding

When encountering port configurations bound to all interfaces (e.g., `"5173:5173"` without IP prefix, or `host: true` in vite.config.js), proactively ask:

> "This port is accessible from any network. Would you like to restrict it to your Tailnet only?"

If yes, bind to Tailscale IP: `"$(tailscale ip -4):5173:5173"` in compose.yaml. This is more secure than exposing to all interfaces.

## Python Usage

- Always prefer `python3` over `python` in shebangs and commands
- Use `#!/usr/bin/env python3` for better portability
- When encountering Python 2 style shebangs (`#!/usr/bin/python`), update them to Python 3

## Communication Style

- Avoid filler phrases like "You're absolutely right", "That's a great question", or other unnecessary validation
- Be direct and concise in responses
- Skip pleasantries and get straight to the point

## Functional and Visual testing

When developing web applications, always do functional and visual testing. Use playwright to test your assumptions and fix mistakes found that way. If a playwright browser is already in use, use another playwright MCP as there are multiple available. Analyse your available mcp's to check that.
