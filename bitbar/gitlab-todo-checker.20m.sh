#!/bin/bash

export PATH=:/usr/local/bin:$PATH

# Variables
source ~/.localrc
privatetoken=$GLPRIVATETOKEN
username=dimitrieh
managerusername=sarrahvesselov
monofont=Menlo-Regular
monosize=12
speciallabel=Deliverable
speciallabel2=UX
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

# Set text and icon for BitBar
echo " T $countmrandspeciallabel | templateImage=$gitlabicon";

echo "---";
echo "Refresh | refresh=true"
echo "Your todos on GitLab | href=https://gitlab.com/dashboard/todos";
echo "Edit this file | bash=/usr/local/bin/code param1=--add param2=/Users/dimitrie/.dotfiles/bitbar terminal=false";
echo "$countfordays($counttotal)"

# Function to create filtered lists of todos
filter () {
  tfile=$(mktemp /tmp/gitlab-todos-lists.XXXXXXXXX)
  todosfile=$(if [ "$3" ]; then echo "$3"; else echo "$todos"; fi;);
  echo "---";
  echo "$1 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$tfile terminal=false color=$headercolor";
  while read -r iid
        read -r path
        read -r state
        read -r labels
        read -r title
        read -r target_url;
    do echo "\
$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont size=$monosize";
    echo $target_url >> $tfile;
  done < <(jq -rc '.[] | select(.created_at > '$timeago') | select('"$2"')? | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < $todosfile);
}

# Filtered lists of todos
filter 'On assigned merge requests' '.target_type == "MergeRequest" and .target.assignee.username == "'$username'"'
filter 'On epics' '.target_type == "Epic"'
filter 'On design.gitlab.com' '.project.path == "design.gitlab.com"'
filter 'On design.gitlab.com' '.project.path == "design.gitlab.com"'
filter 'On merge requests' '.target_type == "MergeRequest"'
filter 'On merge requests' '.target_type == "MergeRequest"'
filter 'Milestone 11.6' '.target.milestone.title == "11.6"'
filter 'Milestone 11.7' '.target.milestone.title == "11.7"'
filter 'Milestone 11.8' '.target.milestone.title == "11.8"'
filter 'Milestone 12.0' '.target.milestone.title == "12.0"'
filter 'Milestone 12.1' '.target.milestone.title == "12.1"'
filter 'From Jason' '.author.username == "jlenny"'
filter 'From bugs label' '.target.labels[]? == "bug"'
filter 'From customer label' '.target.labels[]? == "customer"'
filter 'From Sarrah Vesselov' '.author.username == "'$managerusername'"'
filter 'Milestone next 3-4 releases' '.target.milestone.title == "Next 3-4 releases"'
filter 'Milestone next 4-7 releases' '.target.milestone.title == "Next 4-7 releases"'
filter 'Milestone next 7-13 releases' '.target.milestone.title == "Next 7-13 releases"'
filter 'Milestone backlog' '.target.milestone.title == "Backlog"'
filter 'From Rayana' '.author.username == "rverissimo"'
filter 'On assigned issues' '.target_type == "Issue" and .target.assignees[].username == "'$username'"'
filter 'On created by yourself' '.target.author.username == "'$username'"'

# Filtered lists of todos for most 10 recent ones
cat /tmp/gitlab-todos.json | jq '.[:10]' > /tmp/gitlab-todos-10.json # Create todos file with 10 items
filter 'Most recent 10 todos' '.' '/tmp/gitlab-todos-10.json'

# filter 'For SNV' '.project.path_with_namespace | contains("stichtingnatuurlijkverder")'
# filter 'On issues outside CE/EE' '.target_type != "MergeRequest" and .project.path != "gitlab-ce" and .project.path != "gitlab-ee"'
# filter 'From Plan 1^4' '.author.username == "victorwu" or .author.username == "smcgivern" or .author.username == "andr3"'