# Claude Code function with MCP configuration and 1Password environment injection
# Function to handle system commands without MCP, user commands with MCP
claude() {
  if [[ "$1" =~ ^(config|mcp|migrate-installer|setup-token|doctor|update|install|--help|--version|-h|-v|help|version)$ ]]; then
    command claude "$@"
  else
    op run -- command claude --mcp-config ~/.claude/mcp.json "$@"
  fi
}
