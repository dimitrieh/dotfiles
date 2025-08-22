# Enhanced completion system

# Case insensitive matching with fuzzy/partial matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# Menu selection - use arrow keys to navigate completions
zstyle ':completion:*' menu select

# Colored completions matching LS_COLORS
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Group completions by category
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# Better directory completion
zstyle ':completion:*' special-dirs true

# Cache completions for better performance
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# More intelligent completion for kill command
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
