# Detect Homebrew prefix automatically and export for other scripts
if command -v brew >/dev/null 2>&1; then
  export HOMEBREW_PREFIX=$(brew --prefix)
elif [[ "$(uname -m)" == "arm64" ]] && [[ -d "/opt/homebrew" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi

export PATH="./bin:${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:$ZSH/bin:$PATH"
export MANPATH="${HOMEBREW_PREFIX}/man:${HOMEBREW_PREFIX}/mysql/man:${HOMEBREW_PREFIX}/git/man:$MANPATH"

# To use GNU core utilities with their normal names | https://www.gnu.org/software/coreutils
export PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"

# PostgreSQL binary path
if [ -d "${HOMEBREW_PREFIX}/opt/postgresql/bin" ]; then
  export PATH="${HOMEBREW_PREFIX}/opt/postgresql/bin:$PATH"
fi

# OpenJDK binary path
if [ -d "${HOMEBREW_PREFIX}/opt/openjdk/bin" ]; then
  export PATH="${HOMEBREW_PREFIX}/opt/openjdk/bin:$PATH"
fi

# User local binary path
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
