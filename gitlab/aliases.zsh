alias migrategl='bin/rake db:migrate RAILS_ENV=development'

alias gdkce="cd ~/Projects/gdk-ce/gitlab"
alias gdkcemg="gdkce && migrategl && o http://localhost:3000"
alias gdkcerun="gdkce && npm install && bundle install && gdk run & (sleep 120 && gdkcemg)"

alias gdkee="cd ~/Projects/gdk-ee/gitlab"
alias gdkeemg="gdkee && migrategl && o http://localhost:3001"
alias gdkeerun="gdkee && npm install && bundle install && gdk run & (sleep 120 && gdkeemg)"

alias gldes="cd ~/Projects/gitlab-design"

alias gltodos="chromeless https://gitlab.com/dashboard/todos"
alias glissues="chromeless https://gitlab.com/dashboard/issues?assignee_id=489558"
alias glmrs="chomeless https://gitlab.com/dashboard/merge_requests?assignee_id=489558"

alias cp3000='lsof | grep ":3000"'
alias cp3001='lsof | grep ":3001"'

alias kill9="kill -9" #kill -9 ID found with lsof

alias gdkkill="killall chromedriver chromium-browser ruby ruby2.3 node postgres redis redis-server" #kill all lingering processes, if not working use -9
