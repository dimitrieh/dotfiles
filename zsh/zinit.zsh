# Zinit plugin manager configuration
# Initialize Zinit with fallback paths
if [[ -f /usr/local/opt/zinit/zinit.zsh ]]; then
  source /usr/local/opt/zinit/zinit.zsh
elif [[ -f /opt/homebrew/share/zinit/zinit.zsh ]]; then
  source /opt/homebrew/share/zinit/zinit.zsh
elif [[ -f ~/.zinit/zinit.zsh ]]; then
  source ~/.zinit/zinit.zsh
else
  echo "Warning: Zinit not found. Please install zinit or update the path."
  return
fi

# Load modern plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-completions

# Load existing autosuggestions via Zinit instead of manual sourcing
zinit light zsh-users/zsh-autosuggestions

# Key bindings for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# History substring search configuration
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'

# Syntax highlighting configuration
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'