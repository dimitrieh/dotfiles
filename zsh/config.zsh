# PS1 configuration moved to prompt.zsh to avoid conflicts

export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

# History configuration (HISTFILE also set in zshrc.symlink for early initialization)
HISTSIZE=10000
SAVEHIST=10000

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt HIST_VERIFY
# Removed redundant SHARE_HISTORY (set below with INC_APPEND_HISTORY)
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF

setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE # don't record commands starting with space
setopt HIST_VERIFY # show command with history expansion to user before running it

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char

# Enhanced key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Better completion navigation
bindkey '^[[Z' reverse-menu-complete  # Shift-Tab
bindkey '^I' expand-or-complete-prefix # Tab completion

# Enhanced autosuggestion acceptance
bindkey '^F' forward-char # Accept suggestion with Ctrl+F
bindkey '^E' end-of-line  # Accept entire suggestion with Ctrl+E
