#!/bin/bash

export PATH=:/usr/local/bin:$PATH

# Variables
source ~/.localrc
privatetoken=$GLPRIVATETOKEN
username=dimitrieh
monofont=Menlo-Regular
monosize=12
headercolor=#444444
days=90
mainlabel=Package
speciallabel=Deliverable
speciallabel2=Stretch
allissues="/tmp/gitlab-issues.json"
gitlabicon="iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII="

# Get total number of todo pages if 100 issues per page
TPAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/groups/9970/issues/?scope=all&state=opened&labels=$mainlabel&per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');

# Clear JSON file
> $allissues

# Clear sublists
rm -f /tmp/gitlab-issues-lists.*

# Write issues to JSON file for each page
for i in $(seq 1 $TPAGES); do
  curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/groups/9970/issues/?scope=all&state=opened&labels=$mainlabel&state=opened&per_page=100&page=$i" | jq -rc '.[].updated_at |= (sub("\\....Z";"Z") | fromdate)' >> $allissues;

  # If GitLab is not responding, exit with error message
  if grep -Fq "GitLab is not responding" $allissues
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
jq -s 'add' $allissues > /tmp/issues.tmp && mv /tmp/issues.tmp $allissues

# Count of issues
counttotal=$(jq -s '.[] | length' $allissues);

mainlabelcapitals=$(echo "$mainlabel" | tr '[:lower:]' '[:upper:]')
# Set text and icon for BitBar
echo " ${mainlabelcapitals:0:2} $counttotal | templateImage=$gitlabicon";

echo "---";
echo "Refresh | refresh=true"
echo "Your issues on GitLab | href=https://gitlab.com/dashboard/issues";
echo "Edit this file | bash=/usr/local/bin/code param1=--add param2=/Users/dimitrie/.dotfiles/bitbar terminal=false";

# Function to create filtered lists of issues
filter () {
  tfile=$(mktemp /tmp/gitlab-issues-lists.XXXXXXXXX)
  issuesfile=$(if [ "$3" ]; then echo "$3"; else echo "$allissues"; fi;);
  echo "---";
  echo "$1 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$tfile terminal=false color=$headercolor";
  while read -r iid
        read -r labels
        read -r title
        read -r web_url;
    do echo "\
$(printf %-15.15s "$(echo $web_url | sed -E 's#([^/]+)/(issues|merge_requests)/[0-9]+#\1#' | sed -E 's#.*/([^/]+)#\1#')") $([[ $web_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$title") | href=$web_url font=$monofont size=$monosize";
    echo $web_url >> $tfile;
  done < <(jq -rc ''"$2"' | .iid,.labels,.title,.web_url' < $issuesfile);
}

# Function to create filtered lists of epics
filterepics () {
  tfile=$(mktemp /tmp/gitlab-issues-lists.XXXXXXXXX)
  issuesfile=$(if [ "$3" ]; then echo "$3"; else echo "$allissues"; fi;);
  echo "---";
  echo "$1 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$tfile terminal=false color=$headercolor";
  while read -r iid
        read -r title;
    do echo "\
$(printf %-15.15s "gitlab-org") \
$(printf '%-6s' "&$iid")     \
$(printf %-75.75s "$title") | href=https://gitlab.com/groups/gitlab-org/-/epics/$iid font=$monofont size=$monosize";
    echo $web_url >> $tfile;
  done < <(jq -rc ''"$2"' | .iid,.title' < $issuesfile);
}

# Lists of epics
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/groups/9970/epics/?labels=$mainlabel&state=opened&order_by=updated_at&per_page=100" > /tmp/gitlab-issues-epics.json # Create issues file with 10 items
filterepics 'Epics' '.[] | select(.)?' '/tmp/gitlab-issues-epics.json'

# Filtered lists of todos
filter 'Milestone 11.8' '.[] | select(.milestone.title == "11.8")?'
filter 'Milestone 11.9' '.[] | select(.milestone.title == "11.9")?'
filter 'Milestone 11.10' '.[] | select(.milestone.title == "11.10")?'
filter 'Milestone 11.11' '.[] | select(.milestone.title == "11.11")?'
filter 'Milestone 12.0' '.[] | select(.milestone.title == "12.0")?'
filter 'Milestone 12.1' '.[] | select(.milestone.title == "12.1")?'
filter 'Upvotes sorted (>25 upvotes)' 'sort_by(.upvotes) | reverse[] | select(.upvotes > 25)'
filter 'Comments sorted (>25 comments)' 'sort_by(.user_notes_count) | reverse[] | select(.user_notes_count > 25)'
filter 'bugs label' '.[] | select(.labels[]? == "bug")?'
filter 'customer label' '.[] | select(.labels[]? == "customer")?'
filter 'Milestone next 3-4 releases' '.[] | select(.milestone.title == "Next 3-4 releases")?'
filter 'Milestone next 4-7 releases' '.[] | select(.milestone.title == "Next 4-7 releases")?'
filter 'Milestone next 7-13 releases' '.[] | select(.milestone.title == "Next 7-13 releases")?'
filter 'Milestone backlog' '.[] | select(.milestone.title == "Backlog")?'
filter 'No milestone' '.[] | select(.milestone.title == null)?'

# Filtered lists of issues for most 10 recent created ones
cat /tmp/gitlab-issues.json | jq '.[:10]' > /tmp/gitlab-issues-created-10.json # Create issues file with 10 items
filter 'Last created 10 issues' '.[] | select(.)?' '/tmp/gitlab-issues-created-10.json'

# Filtered lists of issues for most 10 recently updated ones
cat /tmp/gitlab-issues.json | jq 'sort_by(.updated_at) | reverse[:10]' > /tmp/gitlab-issues-updated-10.json # Create issues file with 10 items
filter 'Last updated 10 issues' '.[] | select(.)?' '/tmp/gitlab-issues-updated-10.json'