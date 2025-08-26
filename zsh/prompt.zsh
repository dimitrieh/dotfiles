# Activate for profiling and run in terminal
# zmodload zsh/zprof

autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi
#
git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

# Async git status with caching
typeset -g _git_status_cache=""
typeset -g _git_status_cache_dir=""
typeset -g _git_status_cache_time=0

git_dirty() {
  # Return cached result if in same directory and recent
  local current_time=$(date +%s)
  if [[ "$PWD" == "$_git_status_cache_dir" && $(($current_time - $_git_status_cache_time)) -lt 10 ]]; then
    echo "$_git_status_cache"
    return
  fi

  # Check if in git repo quickly
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    _git_status_cache=""
    _git_status_cache_dir="$PWD"
    _git_status_cache_time=$current_time
    echo ""
    return
  fi

  # Use porcelain format for faster status check
  local status_output
  status_output=$(git status --porcelain 2>/dev/null)
  local branch_name=$(git_prompt_info)
  
  if [[ -z "$status_output" ]]; then
    _git_status_cache="on %{$fg_bold[green]%}${branch_name}%{$reset_color%}"
  else
    _git_status_cache="on %{$fg_bold[red]%}${branch_name}%{$reset_color%}"
  fi
  
  _git_status_cache_dir="$PWD"
  _git_status_cache_time=$current_time
  echo "$_git_status_cache"
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
 echo "${ref#refs/heads/}"
}

# Cached unpushed status check
typeset -g _unpushed_cache=""
typeset -g _unpushed_cache_dir=""
typeset -g _unpushed_cache_time=0

unpushed () {
  $git cherry -v @{upstream} 2>/dev/null
}

need_push () {
  # Return cached result if in same directory and recent
  local current_time=$(date +%s)
  if [[ "$PWD" == "$_unpushed_cache_dir" && $(($current_time - $_unpushed_cache_time)) -lt 10 ]]; then
    echo "$_unpushed_cache"
    return
  fi

  # Quick check if we have an upstream
  if ! git rev-parse @{upstream} >/dev/null 2>&1; then
    _unpushed_cache=" "
    _unpushed_cache_dir="$PWD"
    _unpushed_cache_time=$current_time
    echo " "
    return
  fi

  # Check for unpushed commits
  local unpushed_output
  unpushed_output=$(git cherry -v @{upstream} 2>/dev/null)
  
  if [[ -z "$unpushed_output" ]]; then
    _unpushed_cache=" "
  else
    _unpushed_cache=" with %{$fg_bold[magenta]%}unpushed%{$reset_color%} "
  fi
  
  _unpushed_cache_dir="$PWD"
  _unpushed_cache_time=$current_time
  echo "$_unpushed_cache"
}

# This takes care of displaying the dir structure you're currently in up to
# three levels. Also it detects so when you are in a git repository or submodule
# and it will keep the root always visible in a different color.
# http://stackoverflow.com/questions/16147173/command-prompt-directory-styling/16214977#16214977
directory_name() {
    PROMPT_PATH=""

    CURRENT=`dirname ${PWD}`
    if [[ $CURRENT = / ]]; then
        PROMPT_PATH=""
    elif [[ $PWD = $HOME ]]; then
        PROMPT_PATH=""
    else
        if [[ -d $(git rev-parse --show-toplevel 2>/dev/null) ]]; then
            # We're in a git repo.
            BASE=$(basename $(git rev-parse --show-toplevel))
            if [[ $PWD = $(git rev-parse --show-toplevel) ]]; then
                # We're in the root.
                PROMPT_PATH=""
            else
                # We're not in the root. Display the git repo root.
                GIT_ROOT="%{$fg_bold[blue]%}${BASE}%{$reset_color%}"

                PATH_TO_CURRENT="${PWD#$(git rev-parse --show-toplevel)}"
                PATH_TO_CURRENT="${PATH_TO_CURRENT%/*}"

                PROMPT_PATH="${GIT_ROOT}${PATH_TO_CURRENT}/"
            fi
        else
            PROMPT_PATH=$(print -P %3~)
            PROMPT_PATH="${PROMPT_PATH%/*}/"
        fi
    fi
    echo "${PROMPT_PATH}%{$fg_bold[cyan]%}%1~%{$reset_color%}"
}

# displays the exec time of the last command if set threshold was exceeded
prompt_pure_cmd_exec_time() {
    local stop=$(date +%s)
    local start=${cmd_timestamp:-$stop}
    integer elapsed=$stop-$start
    (($elapsed > ${PURE_CMD_MAX_EXEC_TIME:=3})) && echo ${elapsed}s
}

prompt_pure_preexec() {
    cmd_timestamp=$(date +%s)
}

prompt_pure_precmd() {
    local stop=$(date +%s)
    local start=${cmd_timestamp:-$stop}
    integer elapsed=$stop-$start

    if [[ $elapsed > ${PURE_CMD_MAX_EXEC_TIME:=3} ]]; then
        # print -P "%F{yellow}$(prompt_pure_cmd_exec_time)%f"
        echo "$fg_bold[yellow]${elapsed}s$reset_color"
    fi
    # reset value since `preexec` isn't always triggered
    unset cmd_timestamp
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_pure_precmd
add-zsh-hook preexec prompt_pure_preexec

export RANGER_LOAD_DEFAULT_RC="false"
export GIT_RADAR_FORMAT="%{changes: }%{remote: }%{local: }%{stash}"

# SSH detection function
ssh_indicator() {
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] || [[ "$SSH_CONNECTION" ]]; then
        echo "%{$fg_bold[blue]%}🌐 %{$reset_color%}"
    fi
}

if command -v git-radar > /dev/null 2>&1; then
  export PROMPT=$'\n  $(ssh_indicator)$(directory_name) $(git_dirty)$(need_push)\$(git-radar --zsh --fetch) \n%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%}❯)%{$fg_bold[green]%}❯%{$reset_color%} '
else
  export PROMPT=$'\n  $(ssh_indicator)$(directory_name) $(git_dirty)$(need_push) \n%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%}❯)%{$fg_bold[green]%}❯%{$reset_color%} '
fi

set_prompt () {
  export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"
  # Set cursor to steady bar (non-blinking)
  printf '\033[6 q'
}
#
#
#
precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}

# Activate for profiling and run in terminal
# zprof
