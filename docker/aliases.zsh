alias d='docker $*'
alias d-c='docker-compose $*'
alias ddelc='docker rm $(docker ps -a -q)' # Delete all containers
alias ddeli='docker rmi $(docker images -q)' # Delete all images
