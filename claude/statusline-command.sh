#!/bin/bash

# Read JSON input
input=$(cat)

# Extract current directory from JSON
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
cd "$current_dir" || exit 1

# Directory name function (simplified version of your directory_name)
directory_name() {
    local prompt_path=""
    local current=$(dirname "${PWD}")
    
    if [[ $current = / ]]; then
        prompt_path=""
    elif [[ $PWD = $HOME ]]; then
        prompt_path=""
    else
        if git rev-parse --show-toplevel >/dev/null 2>&1; then
            # We're in a git repo
            local base=$(basename "$(git rev-parse --show-toplevel)")
            if [[ $PWD = $(git rev-parse --show-toplevel) ]]; then
                # We're in the root
                prompt_path=""
            else
                # We're not in the root. Display the git repo root
                local git_root="${base}"
                local path_to_current="${PWD#$(git rev-parse --show-toplevel)}"
                path_to_current="${path_to_current%/*}"
                prompt_path="${git_root}${path_to_current}/"
            fi
        else
            # Not in git repo, show last 3 directories
            prompt_path=$(pwd | sed "s|$HOME|~|" | awk -F/ '{if(NF>3) printf ".../%s/%s/", $(NF-1), $NF; else print}' | sed 's|/$||')
            prompt_path="${prompt_path%/*}/"
        fi
    fi
    printf "%s%s" "$prompt_path" "$(basename "$PWD")"
}

# Git status function
git_dirty() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo ""
        return
    fi
    
    local branch=$(git symbolic-ref HEAD 2>/dev/null | sed 's|refs/heads/||')
    if [[ -z "$branch" ]]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
    fi
    
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        printf "on %s" "$branch"
    else
        printf "on %s" "$branch"
    fi
}

# Check for unpushed commits
need_push() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo ""
        return
    fi
    
    # Check if we have unpushed commits
    if git rev-parse @{upstream} >/dev/null 2>&1; then
        local unpushed=$(git cherry -v @{upstream} 2>/dev/null)
        if [[ -n "$unpushed" ]]; then
            printf " with unpushed"
        fi
    fi
}

# Build the status line
printf "  %s %s%s " "$(directory_name)" "$(git_dirty)" "$(need_push)"