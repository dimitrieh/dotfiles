# Enhanced functions and shell improvements

# Command-not-found with suggestions
command_not_found_handler() {
  local command="$1"

  # Simple suggestions for common typos
  case "$command" in
    'cd..' | 'cd..') echo "Did you mean: cd .."; return 127 ;;
    'll' | 'sl') echo "Did you mean: ls"; return 127 ;;
    'eixt' | 'exut' | 'exi') echo "Did you mean: exit"; return 127 ;;
    'celar' | 'clr') echo "Did you mean: clear"; return 127 ;;
    'gti') echo "Did you mean: git"; return 127 ;;
  esac
  
  echo "zsh: command not found: $command" >&2
  return 127
}

# Directory creation and navigation
take() {
  [[ -z "$1" ]] && { echo "Usage: take <directory>"; return 1; }
  [[ "$1" =~ ^[[:space:]]*$ ]] && { echo "Error: Directory name cannot be empty or just spaces"; return 1; }
  mkdir -p "$1" && cd "$1"
}

# Universal archive extraction
extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# File finder (fd is already aliased as 'ff')
# Fallback for systems without fd
findfile() {
  if command -v fd >/dev/null 2>&1; then
    fd "$@"
  else
    find . -iname "*$1*"
  fi
}

# Process finder  
pf() {
  ps aux | head -1
  ps aux | grep -v grep | grep -i "$1"
}

# Enhanced history search 
histsearch() {
  if [[ $# -eq 0 ]]; then
    history | tail -20
  else
    history | grep -i "$1"
  fi
}

# Weather function
weather() {
  local location="${1:-}"
  curl -s "http://wttr.in/$location" | head -20
}

# Git branch switching with fuzzy finder (gb is aliased to 'git branch')
gitswitch() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Not in a git repository"
    return 1
  fi
  
  if command -v fzf >/dev/null 2>&1; then
    git branch | grep -v "^\*" | sed 's/^[[:space:]]*//' | fzf --height=20% --reverse --info=inline | xargs git checkout
  else
    echo "Available branches:"
    git branch
    echo "Use: git checkout <branch-name>"
  fi
}

# Upward directory navigation with pattern matching
up() {
  local dir pwd
  local -i num=${1:-1}
  
  if [[ $num -eq $num ]] 2>/dev/null; then
    # It's a number - go up that many levels
    dir=""
    for ((i=1; i<=num; i++)); do
      dir="../$dir"
    done
    cd "$dir"
  else
    # It's a pattern - find the directory
    pwd=$(pwd)
    dir=$(echo "$pwd" | sed -e "s|/[^/]*$||" -e "s|.*\(/.*$1[^/]*/\).*|\1|")
    if [[ "$dir" != "$pwd" ]]; then
      cd "$dir"
    else
      echo "Directory containing '$1' not found in path"
      return 1
    fi
  fi
}

# Shell reload function (reload is aliased to exec $SHELL)
zshreload() {
  echo "Reloading zsh configuration..."
  source ~/.zshrc || source ~/.dotfiles/zsh/zshrc.symlink
  echo "Configuration reloaded!"
}

# Alternative to take function
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Better which command with type information
which() {
  builtin which "$@"
  if command -v "$1" >/dev/null 2>&1; then
    echo "Type: $(type "$1")"
  fi
}