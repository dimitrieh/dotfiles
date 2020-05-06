#!/bin/bash
source ~/.localrc
privatetoken=$GLPRIVATETOKEN
username=dimitrieh
assigneeid=489558
monosize=12
monofont=Menlo-Regular
speciallabel=Deliverable
headercolor=#444444

export PATH="$PATH:/usr/local/bin"

# Getting all issue assignments
> /tmp/gitlab-assignments-checker-1-1.json
PAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/issues?scope=all&assignee_id=$assigneeid&state=opened&per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');
for i in $(seq 1 $PAGES); do
  curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/issues?scope=all&assignee_id=$assigneeid&state=opened&per_page=100&page=$i" >> /tmp/gitlab-assignments-checker-1-1.json;
done

# Getting all merge request assignments
> /tmp/gitlab-assignments-checker-2-1.json
PAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/merge_requests?scope=all&assignee_id=$assigneeid&state=opened&per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');
for i in $(seq 1 $PAGES); do
  curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/merge_requests?scope=all&assignee_id=$assigneeid&state=opened&per_page=100&page=$i" >> /tmp/gitlab-assignments-checker-2-1.json;
done

# Getting all assignments awarded a star emoji by you
> /tmp/gitlab-assignments-checker-3-1.json
PAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/issues?scope=all&assignee_id=$assigneeid&my_reaction_emoji=star&state=opened&per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');
for i in $(seq 1 $PAGES); do
  curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/issues?scope=all&assignee_id=$assigneeid&my_reaction_emoji=star&state=opened&per_page=100&page=$i" >> /tmp/gitlab-assignments-checker-3-1.json;
done

cat /tmp/gitlab-assignments-checker-1-1.json > /tmp/gitlab-assignments-checker-4-1.json

# Creating count for assigned mr's, all assigned issues
number1=$(cat /tmp/gitlab-assignments-checker-2-1.json | jq -rc '.[] | .web_url' | wc -l | tr -d '[:space:]')
number2=$(cat /tmp/gitlab-assignments-checker-1-1.json | jq -rc '.[] | .web_url' | wc -l | tr -d '[:space:]')

echo " A ($number1) $number2 | templateImage=iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII=";

echo "---";
echo "Refresh | refresh=true"
echo "Your assigned merge requests on GitLab | href=https://gitlab.com/dashboard/merge_requests?assignee_id=$assigneeid";
echo "Your assigned issues on GitLab | href=https://gitlab.com/dashboard/issues?assignee_id=$assigneeid";
echo "Edit this file | bash=code param1=--add param2=/Users/dimitrie/.dotfiles/bitbar terminal=false";

echo "---";
file=/tmp/gitlab-assignments-checker-1-assigned-merge-requests.txt
> $file
echo "Assigned merge requests | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r labels
      read -r title
      read -r web_url; do
    echo "\
$(printf %-15.15s "$(echo $web_url | sed -E 's#([^/]+)/(issues|merge_requests)/[0-9]+#\1#' | sed -E 's#.*/([^/]+)#\1#')") $([[ $web_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$title")\
| href=$web_url font=$monofont size=$monosize";
echo $web_url >> $file;
done < <(jq -rc '.[] | .iid,.labels,.title,.web_url' < /tmp/gitlab-assignments-checker-2-1.json);

# echo "---";
# file=/tmp/gitlab-assignments-checker-1-workflow-problem-validation.txt
# > $file
# echo "Assigned issues with workflow::problem validation | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
# while read -r iid
#       read -r labels
#       read -r title
#       read -r web_url; do
#     echo "\
# $(printf %-15.15s "$(echo $web_url | sed -E 's#([^/]+)/(issues|merge_requests)/[0-9]+#\1#' | sed -E 's#.*/([^/]+)#\1#')") $([[ $web_url == *'merge_requests'* ]] && echo '!' || echo '#')\
# $(printf '%-6s' "$iid")\
# $(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
# $(printf %-75.75s "$title")\
# | href=$web_url font=$monofont size=$monosize";
# echo $web_url >> $file;
# done < <(jq -rc '.[] | select(.labels[]? == "workflow::problem validation") | .iid,.labels,.title,.web_url' < /tmp/gitlab-assignments-checker-1-1.json);

# echo "---";
# file=/tmp/gitlab-assignments-checker-1-workflow-design.txt
# > $file
# echo "Assigned issues with workflow::design | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
# while read -r iid
#       read -r labels
#       read -r title
#       read -r web_url; do
#     echo "\
# $(printf %-15.15s "$(echo $web_url | sed -E 's#([^/]+)/(issues|merge_requests)/[0-9]+#\1#' | sed -E 's#.*/([^/]+)#\1#')") $([[ $web_url == *'merge_requests'* ]] && echo '!' || echo '#')\
# $(printf '%-6s' "$iid")\
# $(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
# $(printf %-75.75s "$title")\
# | href=$web_url font=$monofont size=$monosize";
# echo $web_url >> $file;
# done < <(jq -rc '.[] | select(.labels[]? == "workflow::design") | .iid,.labels,.title,.web_url' < /tmp/gitlab-assignments-checker-1-1.json);

# echo "---";
# file=/tmp/gitlab-assignments-checker-1-workflow-solution-validation.txt
# > $file
# echo "Assigned issues with workflow::solution validation | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
# while read -r iid
#       read -r labels
#       read -r title
#       read -r web_url; do
#     echo "\
# $(printf %-15.15s "$(echo $web_url | sed -E 's#([^/]+)/(issues|merge_requests)/[0-9]+#\1#' | sed -E 's#.*/([^/]+)#\1#')") $([[ $web_url == *'merge_requests'* ]] && echo '!' || echo '#')\
# $(printf '%-6s' "$iid")\
# $(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
# $(printf %-75.75s "$title")\
# | href=$web_url font=$monofont size=$monosize";
# echo $web_url >> $file;
# done < <(jq -rc '.[] | select(.labels[]? == "workflow::solution validation") | .iid,.labels,.title,.web_url' < /tmp/gitlab-assignments-checker-1-1.json);

# echo "---";
# file=/tmp/gitlab-assignments-checker-1-workflow-planning-breakdown.txt
# > $file
# echo "Assigned issues with workflow::planning breakdown | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
# while read -r iid
#       read -r labels
#       read -r title
#       read -r web_url; do
#     echo "\
# $(printf %-15.15s "$(echo $web_url | sed -E 's#([^/]+)/(issues|merge_requests)/[0-9]+#\1#' | sed -E 's#.*/([^/]+)#\1#')") $([[ $web_url == *'merge_requests'* ]] && echo '!' || echo '#')\
# $(printf '%-6s' "$iid")\
# $(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
# $(printf %-75.75s "$title")\
# | href=$web_url font=$monofont size=$monosize";
# echo $web_url >> $file;
# done < <(jq -rc '.[] | select(.labels[]? == "workflow::planning breakdown") | .iid,.labels,.title,.web_url' < /tmp/gitlab-assignments-checker-1-1.json);

# echo "---";
# file=/tmp/gitlab-assignments-checker-1-scheduling.txt
# > $file
# echo "Assigned issues with workflow::scheduling | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
# while read -r iid
#       read -r labels
#       read -r title
#       read -r web_url; do
#     echo "\
# $(printf %-15.15s "$(echo $web_url | sed -E 's#([^/]+)/(issues|merge_requests)/[0-9]+#\1#' | sed -E 's#.*/([^/]+)#\1#')") $([[ $web_url == *'merge_requests'* ]] && echo '!' || echo '#')\
# $(printf '%-6s' "$iid")\
# $(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
# $(printf %-75.75s "$title")\
# | href=$web_url font=$monofont size=$monosize";
# echo $web_url >> $file;
# done < <(jq -rc '.[] | select(.labels[]? == "workflow::scheduling") | .iid,.labels,.title,.web_url' < /tmp/gitlab-assignments-checker-1-1.json);


echo "---";
file=/tmp/gitlab-assignments-checker-1-all-assigned.txt
> $file
echo "All your assigned issues | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r labels
      read -r title
      read -r web_url; do
    echo "\
$(printf %-15.15s "$(echo $web_url | sed -E 's#([^/]+)/(issues|merge_requests)/[0-9]+#\1#' | sed -E 's#.*/([^/]+)#\1#')") $([[ $web_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$title")\
| href=$web_url font=$monofont size=$monosize";
echo $web_url >> $file;
done < <(jq -rc '.[] | .iid,.labels,.title,.web_url' < /tmp/gitlab-assignments-checker-1-1.json);
