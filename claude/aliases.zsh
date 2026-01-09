# Claude Code function with MCP configuration and 1Password environment injection
# Function to handle system commands without MCP, user commands with MCP
# Default MCPs: context7, deepwiki, github, playwright
claude() {
  # Check for system commands that don't need MCP
  if [[ "$1" =~ ^(config|mcp|migrate-installer|setup-token|doctor|update|install|--help|--version|-h|-v|help|version)$ ]]; then
    command claude "$@"
    return $?
  fi

  # Check for no MCP flag
  if [[ "$1" == "-nomcp" ]]; then
    shift # Remove -nomcp from arguments
    op run -- command claude "$@"
    return $?
  fi

  # Check for jq dependency
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Install with: brew install jq" >&2
    return 1
  fi

  # Create temporary merged config
  local temp_config=$(mktemp)
  echo '{"mcpServers":{}}' > "$temp_config"

  # Determine which MCPs to load
  local mcp_list=""
  if [[ "$1" == "-mcp" ]] && [[ -n "$2" ]]; then
    # Specific MCPs requested
    shift # Remove -mcp from arguments
    mcp_list="$1"
    shift # Remove MCP list from arguments
    # Special case: "all" loads everything
    if [[ "$mcp_list" == "all" ]]; then
      mcp_list=$(ls -1 "$HOME/.claude/mcp-configs/"*.json 2>/dev/null | xargs -n1 basename | sed 's/\.json$//' | tr '\n' ',')
      mcp_list=${mcp_list%,} # Remove trailing comma
    fi
  else
    # Default: load context7, deepwiki, github, and playwright
    mcp_list="context7,deepwiki,github,playwright"
  fi

  # Split comma-separated MCP names and merge configs
  IFS=',' read -rA MCPS <<< "$mcp_list"
  for mcp in "${MCPS[@]}"; do
    local config_file="$HOME/.claude/mcp-configs/${mcp}.json"
    if [[ -f "$config_file" ]]; then
      # Merge using jq
      jq -s '.[0].mcpServers * .[1].mcpServers | {mcpServers: .}' "$temp_config" "$config_file" > "${temp_config}.tmp" && mv "${temp_config}.tmp" "$temp_config"
    else
      echo "Warning: MCP config for '${mcp}' not found" >&2
    fi
  done

  # Run claude with the merged config
  op run -- command claude --mcp-config "$temp_config" "$@"
  local exit_code=$?

  # Clean up temp file
  rm -f "$temp_config"
  return $exit_code
}
