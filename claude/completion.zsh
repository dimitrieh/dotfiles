# Zsh completion for claude function with MCP support

# Only set up completion if we're in an interactive shell
if [[ -o interactive ]]; then
  _claude_completion() {
    local -a mcp_configs
    local mcp_dir="$HOME/.claude/mcp-configs"
    
    # Get list of available MCP configs
    if [[ -d "$mcp_dir" ]]; then
      mcp_configs=(${(f)"$(ls -1 $mcp_dir/*.json 2>/dev/null | xargs -n1 basename | sed 's/\.json$//')"})
    fi
    
    local curcontext="$curcontext" state line
    typeset -A opt_args
    
    # First check if we're completing the first argument
    if [[ ${#words[@]} -eq 2 ]]; then
      local -a options
      options=(
        '-nomcp:Run without any MCP servers'
        '-mcp:Specify MCP servers to load'
        'config:Manage configuration'
        'mcp:Manage MCP servers'
        'doctor:Check system health'
        'update:Update Claude'
        'help:Show help'
        '--help:Show help'
        '--version:Show version'
      )
      _describe 'claude options' options
      return
    fi
    
    # If the previous word was -mcp, complete MCP names
    if [[ ${words[CURRENT-1]} == "-mcp" ]]; then
      local -a all_options
      all_options=(
        'all:Load all available MCPs'
        "${mcp_configs[@]}"
      )
      
      # Common combinations
      local -a combinations
      combinations=(
        'exa,context7:Default MCPs (web search + docs)'
        'exa,notion:Web search and Notion'
        'github,notion:GitHub and Notion'
        'playwright,exa:Browser automation and web search'
      )
      
      _describe 'available MCPs' all_options
      _describe 'common combinations' combinations
      
      # Handle comma-separated completion
      if [[ "$PREFIX" == *,* ]]; then
        # Extract what's already typed
        local already_typed="${PREFIX%,*},"
        # Get the part after the last comma
        local partial="${PREFIX##*,}"
        # Set up completion for the next MCP
        compadd -P "$already_typed" -- "${mcp_configs[@]}"
      fi
      return
    fi
    
    # Default file completion for other cases
    _files
  }
  
  # Register the completion function
  compdef _claude_completion claude
fi