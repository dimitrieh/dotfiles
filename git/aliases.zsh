alias g="git"
alias ga="git add"
alias gstash= "git stash save --include-untracked"
alias gprune="git fetch --prune"

alias glog="git log --all --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue) <%an>%Creset' --abbrev-commit"
alias glo="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gl="yolog" # https://github.com/karandesai-96/yolog
alias gll="git log --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

alias gf='git fetch'
alias gfp='git fetch origin && git pull'
alias gp='git push origin HEAD'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gcb='git checkout -b'
alias gcrb='git-checkout-remote-branch'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gac='git add -A && git commit -m'
alias gpr='git pull --rebase'

alias gdels="git checkout ." # Delete all changes in the Git repository, but leave unstaged things
alias gdelh="git clean -f" # Delete all changes in the Git repository, including untracked files
alias gdell="git reset HEAD^" # Delete last commit
alias gundo="git reset --soft HEAD^"

alias gcm="git checkout master"
# Rebase and squash
# 1. Do your edits on your branch and commit those
# 2. git checkout master
# 3. git pull origin master
# 4. git checkout YOUR_BRANCH
# 5. git rebase -i master (or "git rebase -i origin/master" if you want to skip updating your own master branch)
# 6. squash and Rebase ("git add" for fixed conflicts)
# 7. git push -f (origin YOUR_BRANCH)
