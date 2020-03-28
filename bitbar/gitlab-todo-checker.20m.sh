#!/bin/bash

export PATH=:/usr/local/bin:$PATH

# Variables
source ~/.localrc
privatetoken=$GLPRIVATETOKEN
username=dimitrieh
managerusername=nudalova
directorusername=clenneville
monofont=Menlo-Regular
monosize=12
speciallabel=Deliverable
headercolor=#444444
days=90
todos="/tmp/gitlab-todos.json"
gitlabicon="iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII="

# Calculate and convert time
present=$(jq -n 'now' | awk '{print int($0)}')
daysago=$(($days * 86400))
timeago=$(($present - $daysago))

# Get total number of todo pages if 100 todos per page
TPAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');

# Clear JSON file
> $todos

# Clear sublists
rm -f /tmp/gitlab-todos-lists.*

# Write todos to JSON file for each page
for i in $(seq 1 $TPAGES); do
  curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=100&page=$i" | jq -rc '.[].created_at |= (sub("\\....Z";"Z") | fromdate)' >> $todos;

  # If GitLab is not responding, exit with error message
  if grep -Fq "GitLab is not responding" $todos
  then
    echo " T | templateImage=$gitlabicon";
    echo "---"
    echo "Error: GitLab is not responding"
    echo "---";
    echo "Retry | refresh=true"
    exit 1
  fi
done

# Join page arrays
jq -s 'add' $todos > /tmp/todos.tmp && mv /tmp/todos.tmp $todos

# Count of todos
counttotal=$(jq -s '.[] | length' $todos);

# Count of todos for configureddays
countfordays=$(cat $todos | jq -rc '.[] | select(.created_at > '$timeago') | .target_url' | wc -l | tr -d ' ');

countmrandspeciallabel=$(($(cat $todos | jq -rc '.[] | select(.created_at > '$timeago') | select(.target_type == "MergeRequest") | .target_url' | wc -l) + $(cat $todos | jq -rc '.[] | select(.created_at > '$timeago') | select(.target_type == "Issue") | select(.target.assignees[].username == "'$username'") | select(.target.labels[]? == "'$speciallabel'") | .target_url' | wc -l)));

# Function to create filtered lists of todos
filter () {
  tfile=$(mktemp /tmp/gitlab-todos-lists.XXXXXXXXX)
  todosfile=$(if [ "$3" ]; then echo "$3"; else echo "$todos"; fi;);
  echo "---";
  echo "$1 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$tfile terminal=false color=$headercolor";
  while read -r iid
        read -r path
        read -r group_path
        read -r state
        read -r labels
        read -r title
        read -r target_url;
    do echo "\
$(printf %-15.15s "$([[ $target_url == *'/-/epics/'* ]] && echo $group_path || echo $path)") $([[ $target_url == *'/merge_requests/'* ]] && echo '!' || echo '')$([[ $target_url == *'/issues/'* ]] && echo '#' || echo '')$([[ $target_url == *'/-/epics/'* ]] && echo '&' || echo '')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont size=$monosize";
    echo $target_url >> $tfile;
  done < <(jq -rc '.[] | select(.created_at > '$timeago') | select('"$2"')? | .target.iid,.project.path,.group.path,.target.state,.target.labels,.target.title,.target_url' < $todosfile);
}

# Set text and icon for BitBar
echo " T $countmrandspeciallabel | templateImage=$gitlabicon";

echo "---";
echo "Refresh | refresh=true"
echo "Your todos on GitLab | href=https://gitlab.com/dashboard/todos";
echo "Edit this file | bash=/usr/local/bin/code param1=--add param2=/Users/dimitrie/.dotfiles/bitbar terminal=false";
echo "$countfordays($counttotal)"

# Filtered lists of todos | JQ cheatsheet https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4
filter 'Merge requests' '.target_type == "MergeRequest"'

filter 'Assigned issues' '.target_type == "Issue" and .target.assignees[].username == "'$username'"'

filter 'workflow::problem validation' '.target.labels[]? == "workflow::problem validation"'
filter 'workflow::design' '.target.labels[]? == "workflow::design"'
filter 'workflow::solution validation' '.target.labels[]? == "workflow::solution validation"'
filter 'workflow::planning breakdown' '.target.labels[]? == "workflow::planning breakdown"'
filter 'workflow::scheduling' '.target.labels[]? == ".target.labels[]? == "workflow::scheduling"'

filter 'Orit' '.author.username == "ogolowinski"'
filter 'Manager' '.author.username == "'$managerusername'"'
filter 'Director' '.author.username == "'$directorusername'"'

filter 'Milestone 12.7' '.target.milestone.title == "12.7"'
filter 'Milestone 12.8' '.target.milestone.title == "12.8"'
filter 'Milestone 12.9' '.target.milestone.title == "12.9"'
filter 'Milestone 12.10' '.target.milestone.title == "12.10"'
filter 'Milestone 13.0' '.target.milestone.title == "13.0"'

filter 'workflow::validation backlog' '.target.labels[]? == ".target.labels[]? == "workflow::validation backlog"'

filter 'Epics' '.target_type == "Epic"'
filter 'Outside CE/EE/Design system' '.target_type != "MergeRequest" and .target_type != "Epic" and .project.path != "gitlab" and .project.path != "gitlab-ce" and .project.path != "gitlab-ee" and .project.path != "design.gitlab.com" and .project.path != "gitlab-design" and .project.path != "gitlab-ui" and .project.path != "gitlab-svgs"'
filter 'Design system' '.project.path == "design.gitlab.com" or .project.path == "gitlab-design" or .project.path == "gitlab-ui" or .project.path == "gitlab-svgs"'

filter 'Capstone' '.author.username == "rogerslaria"'

filter 'Created by yourself' '.target.author.username == "'$username'"'

# Filtered lists of todos for most 10 recent ones
cat /tmp/gitlab-todos.json | jq '.[:10]' > /tmp/gitlab-todos-10.json # Create todos file with 10 items
filter 'Most recent 10 todos' '.' '/tmp/gitlab-todos-10.json'

# Filtered lists of todos for oldest 10
cat /tmp/gitlab-todos.json | jq '.[-10:]' > /tmp/gitlab-todos-last10.json # Create todos file with 10 items
filter 'Oldest 10 todos' '.' '/tmp/gitlab-todos-last10.json'