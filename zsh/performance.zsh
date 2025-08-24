# Performance optimizations for enhanced zsh experience

# Reduce startup time by deferring some expensive operations
autoload -Uz add-zsh-hook

# Optimize path cleanup (remove duplicates)
typeset -aU path

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

# Completion setup will be handled at the end of zsh initialization
# This avoids early compinit calls that slow down startup
# The actual setup is done in zinit.zsh after all plugins are loaded

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

# Set conservative completion cache times
zstyle ':completion:*' cache-policy _zsh_cache_policy
_zsh_cache_policy() {
  # Rebuild if cache is more than a day old
  [[ ! -f $1 || -n $1(mh+24) ]]
}