## CRITICAL: NEVER USE "Kill Bash" or "Kill shell". ASK THE USER FOR PERMISSION WHEN YOU WANT TO KILL A PROCESS OR SHELL

## Best Practices

- Refer to https://www.anthropic.com/engineering/claude-code-best-practices for comprehensive guidance on using Claude Code effectively
- Always review and incorporate workflow improvement recommendations when working with Claude Code
- Continuously monitor the Claude Code best practices URL for updates and new recommendations to optimize development workflows

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
