alias migrategl='bin/rake db:migrate RAILS_ENV=development'

alias gdkce="cd ~/Projects/gdk-ce/gitlab"
alias gdkcemg="gdkce && migrategl && o http://localhost:3000"
alias gdkcerun="gdkce && npm install && bundle install && gdk run & (sleep 120 && gdkcemg)"

alias gdkee="cd ~/Projects/gdk-ee/gitlab"
alias gdkeemg="gdkee && migrategl && o http://localhost:3001"
alias gdkeerun="gdkee && npm install && bundle install && gdk run & (sleep 120 && gdkeemg)"

alias gldes="cd ~/Projects/gitlab-design"

alias kill3000='kill -9 $(lsof -i tcp:3000 -t)'
alias kill3001='kill -9 $(lsof -i tcp:3001 -t)'

alias gdkkill="pkill -f chromedriver chromium-browser ruby ruby2.3 node postgres redis redis-server"
