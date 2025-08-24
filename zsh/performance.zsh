# Performance optimizations for enhanced zsh experience

# Reduce startup time by deferring some expensive operations
autoload -Uz add-zsh-hook

# Lazy load nvm if present (major performance improvement)
if [[ -f "$HOME/.nvm/nvm.sh" ]]; then
  export NVM_DIR="$HOME/.nvm"
  nvm() {
    unfunction nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
  }
fi

# Lazy load rbenv if present
if command -v rbenv >/dev/null 2>&1; then
  rbenv() {
    eval "$(command rbenv init -)"
    rbenv "$@"
  }
fi

# Optimize path cleanup (remove duplicates)
typeset -aU path

# Better prompt updates - only when needed
_zsh_check_git_dirty() {
  local git_dir
  if git_dir=$(git rev-parse --git-dir 2>/dev/null); then
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      echo "dirty"
    else
      echo "clean"
    fi
  fi
}

# Cache expensive operations
typeset -A _zsh_cache_store
_zsh_cache_get() {
  local key="$1"
  local max_age="${2:-300}" # 5 minutes default
  local current_time=$(date +%s)
  
  if [[ -n "${_zsh_cache_store[$key]}" ]]; then
    local cache_data="${_zsh_cache_store[$key]}"
    local cache_time="${cache_data%%:*}"
    local cache_value="${cache_data#*:}"
    
    if (( current_time - cache_time < max_age )); then
      echo "$cache_value"
      return 0
    fi
  fi
  
  return 1
}

_zsh_cache_set() {
  local key="$1"
  local value="$2"
  local current_time=$(date +%s)
  
  _zsh_cache_store[$key]="${current_time}:${value}"
}

# Optimize completions loading
_defer_completion_loading() {
  # Only load completions when needed
  autoload -Uz compinit
  
  # Check if we need to regenerate completions
  if [[ ${ZDOTDIR:-~}/.zcompdump(#qN.mh+24) ]]; then
    compinit -d "${ZDOTDIR:-~}/.zcompdump"
  else
    compinit -C -d "${ZDOTDIR:-~}/.zcompdump"
  fi
}

# Load completions after a delay
_defer_completion_loading

# Precompile zsh files for faster loading
_precompile_zsh_files() {
  local file
  for file in ~/.dotfiles/**/*.zsh(N); do
    if [[ ! -f "${file}.zwc" || "${file}" -nt "${file}.zwc" ]]; then
      zcompile "$file" 2>/dev/null || true
    fi
  done
}

# Only precompile in background if terminal is interactive
if [[ -o interactive ]]; then
  # Run in background to not block startup
  {
    sleep 1
    _precompile_zsh_files
  } &!
fi

# Optimize history file handling
_optimize_history() {
  # Clean up history file periodically
  local hist_file="${HISTFILE:-~/.zsh_history}"
  if [[ -f "$hist_file" && $(wc -l < "$hist_file") -gt 50000 ]]; then
    # Keep last 10000 lines
    tail -10000 "$hist_file" > "${hist_file}.tmp" && mv "${hist_file}.tmp" "$hist_file"
  fi
}

# History optimization can be run manually with: _optimize_history
# Removed automatic random execution to avoid unexpected delays

# Set conservative completion cache times
zstyle ':completion:*' cache-policy _zsh_cache_policy
_zsh_cache_policy() {
  # Rebuild if cache is more than a day old
  [[ ! -f $1 || -n $1(mh+24) ]]
}