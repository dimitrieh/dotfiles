alias remigrate='migrate' # Re-migratex a selected migration | Function in bin
alias migrategl='bin/rake db:migrate RAILS_ENV=development'
alias migrateglfull='bundle exec rake dev:setup RAILS_ENV=development'
#alias deldb="rm -rf ../postgresql/data && cd ../ && make" # Delete db and reconstruct it, be in gitlab folder of gdk
alias dbreset='rake db:drop db:create dev:setup'

alias gdkce="cd ~/Projects/gdk-ce/gitlab"
alias gdkcemg="gdkce && migrategl && o http://localhost:3000"
alias gdkcerun="gdkce && gdk run & (sleep 60 && o http://localhost:3000)"
alias gdkcerunfull="gdkce && npm install && bundle install && gdk run & (sleep 120 && gdkcemg)"

alias gdkee="cd ~/Projects/gdk-ee/gitlab"
alias gdkeemg="gdkee && migrategl && o http://localhost:3001"
alias gdkeerun="gdkee && gdk run & (sleep 60 && o http://localhost:3001)"
alias gdkeerunfull="gdkee && npm install && bundle install && gdk run & (sleep 120 && gdkeemg)"

alias gldes="cd ~/Projects/gitlab-design"

alias kill3000='kill -9 $(lsof -i tcp:3000 -t)'
alias kill3001='kill -9 $(lsof -i tcp:3001 -t)'
alias kill3808='kill -9 $(lsof -i tcp:3808 -t)'

alias gdkkill="pkill -f chromedriver chromium-browser ruby node postgres redis redis-server; kill3000; kill3001; kill3808;"

alias gpgitlab="git-push-gitlab"  # Creates new gitlab project from repository | Function in bin

alias glmr="git lab mr --checkout --id"