export PATH="./bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"

# To use GNU core utilities with their normal names | https://www.gnu.org/software/coreutils
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

# PostgreSQL binary path
if [ -d "/usr/local/opt/postgresql/bin" ]; then
  export PATH="/usr/local/opt/postgresql/bin:$PATH"
fi

# OpenJDK binary path
if [ -d "/usr/local/opt/openjdk/bin" ]; then
  export PATH="/usr/local/opt/openjdk/bin:$PATH"
fi

# User local binary path
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
