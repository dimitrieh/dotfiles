# Zinit plugin manager configuration
# Initialize Zinit using HOMEBREW_PREFIX (set in system/path.zsh)
if [[ -f "${HOMEBREW_PREFIX}/opt/zinit/zinit.zsh" ]]; then
  source "${HOMEBREW_PREFIX}/opt/zinit/zinit.zsh"
elif [[ -f "${HOMEBREW_PREFIX}/share/zinit/zinit.zsh" ]]; then
  source "${HOMEBREW_PREFIX}/share/zinit/zinit.zsh"
elif [[ -f ~/.zinit/zinit.zsh ]]; then
  source ~/.zinit/zinit.zsh
else
  echo "Warning: Zinit not found. Please install zinit or update the path."
  return
fi

# Load defer for startup optimization FIRST
zinit light romkatv/zsh-defer

# Load modern plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search

# Note: zsh-users/zsh-completions is handled by our deferred completion setup
# to prevent early compinit triggering

# Load existing autosuggestions via Zinit instead of manual sourcing
zinit light zsh-users/zsh-autosuggestions

# Load essential plugins (git-open is lightweight)
zinit light paulirish/git-open

# Load zoxide (smart cd replacement)
zinit ice from"gh-r" as"program" mv"zoxide* -> zoxide" pick"zoxide"
zinit load ajeetdsouza/zoxide

# Key bindings for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Enhanced autosuggestions configuration
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_MANUAL_REBIND=true

# History substring search configuration
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_FUZZY=1

# Comprehensive deferred completion and tool initialization
if command -v zsh-defer >/dev/null 2>&1; then
  # Defer completion setup as one atomic operation
  zsh-defer -c '
    # Step 1: Load additional completions plugin if available
    if [[ -d "${ZINIT[PLUGINS_DIR]}/zsh-users---zsh-completions" ]]; then
      zinit light zsh-users/zsh-completions
    fi
    
    # Step 2: Initialize compinit only once
    autoload -Uz compinit
    if [[ ${ZDOTDIR:-~}/.zcompdump(#qN.mh+24) ]]; then
      compinit -d "${ZDOTDIR:-~}/.zcompdump"
    else
      compinit -C -d "${ZDOTDIR:-~}/.zcompdump" 
    fi
    
    # Step 3: Load all completion files after compinit is ready
    typeset -U completion_files
    completion_files=($ZSH/**/*completion.zsh)
    for file in $completion_files; do
      [[ -r "$file" ]] && source "$file"
    done
    unset completion_files
  '
  
  # Defer non-essential productivity plugins
  zsh-defer zinit light MichaelAquilina/zsh-you-should-use
  
  # Also defer zoxide initialization
  zsh-defer eval "$(zoxide init zsh)"
  
  # Defer syntax highlighting configuration for faster startup
  zsh-defer -c '
    # Enhanced syntax highlighting configuration
    ZSH_HIGHLIGHT_STYLES[default]="none"
    ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=red,bold"
    ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=green,underline"
    ZSH_HIGHLIGHT_STYLES[global-alias]="fg=cyan,bold"
    ZSH_HIGHLIGHT_STYLES[precommand]="fg=green,underline"
    ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=blue,bold"
    ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=green,underline"
    ZSH_HIGHLIGHT_STYLES[path]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=cyan,bold"
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]="fg=cyan,bold"
    ZSH_HIGHLIGHT_STYLES[globbing]="fg=blue"
    ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=blue"
    ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=magenta"
    ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=magenta"
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=green"
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=green"
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[rc-quote]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[assign]="fg=blue"
    ZSH_HIGHLIGHT_STYLES[redirection]="fg=yellow"
    ZSH_HIGHLIGHT_STYLES[comment]="fg=black,bold"
    ZSH_HIGHLIGHT_STYLES[named-fd]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[numeric-fd]="fg=cyan"
    ZSH_HIGHLIGHT_STYLES[arg0]="fg=green,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-error]="fg=red,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=blue,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=green,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=magenta,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-4]="fg=yellow,bold"
    ZSH_HIGHLIGHT_STYLES[bracket-level-5]="fg=cyan,bold"
    ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]="standout"
    ZSH_HIGHLIGHT_STYLES[command]="fg=green,bold"
    ZSH_HIGHLIGHT_STYLES[alias]="fg=magenta,bold"
    ZSH_HIGHLIGHT_STYLES[builtin]="fg=cyan,bold"
    ZSH_HIGHLIGHT_STYLES[function]="fg=magenta,bold"
  '
else
  # Fallback: immediate loading if zsh-defer not available
  autoload -Uz compinit
  if [[ ${ZDOTDIR:-~}/.zcompdump(#qN.mh+24) ]]; then
    compinit -d "${ZDOTDIR:-~}/.zcompdump"
  else
    compinit -C -d "${ZDOTDIR:-~}/.zcompdump"
  fi
  
  # Load completion files immediately as fallback
  typeset -U completion_files
  completion_files=($ZSH/**/*completion.zsh)
  for file in $completion_files; do
    [[ -r "$file" ]] && source "$file"
  done
  unset completion_files
  
  eval "$(zoxide init zsh)"
fi