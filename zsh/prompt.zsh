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

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  st=$($git status 2>&1)
  if [[ $st =~ "Not a git repository" ]] ; then
    echo ""
  else
    if [[ "$st" =~ "nothing to commit" ]] ; then
      echo "on %{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}"
    else
      echo "on %{$fg_bold[red]%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
 echo "${ref#refs/heads/}"
}

unpushed () {
  $git cherry -v @{upstream} 2>/dev/null
}

need_push () {
  if [[ $(unpushed) == "" ]]
  then
    echo " "
  else
    echo " with %{$fg_bold[magenta]%}unpushed%{$reset_color%} "
  fi
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

export PROMPT=$'\n  $(directory_name) $(git_dirty)$(need_push)\$(git-radar --zsh --fetch) \n%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%}❯)%{$fg_bold[green]%}❯%{$reset_color%} '

set_prompt () {
  export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}

# Activate for profiling and run in terminal
# zprof

 
