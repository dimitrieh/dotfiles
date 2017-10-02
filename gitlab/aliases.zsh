alias migrategl='bin/rake db:migrate RAILS_ENV=development'
alias gdkce="cd ~/Projects/gdk-ce/gitlab"
alias gdkcemg="gdkce && migrategl && o http://localhost:3000"
alias gdkee="cd ~/Projects/gdk-ee/gitlab"
alias gdkeemg="gdkee && migrategl && o http://localhost:3001"
alias gldes="cd ~/Projects/gitlab-design"
alias gdkrunner="gitlab-ci-multi-runner"

alias gltodos="chromeless https://gitlab.com/dashboard/todos"
alias glissues="chromeless https://gitlab.com/dashboard/issues?assignee_id=489558"
alias glmrs="chomeless https://gitlab.com/dashboard/merge_requests?assignee_id=489558"

alias nbigdkrun="npm install && bundle install && gdk run"

alias cp3000='lsof | grep ":3000"''
alias cp3001='lsof | grep ":3001"''

alias kill9="kill -9"
