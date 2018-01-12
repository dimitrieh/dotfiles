#!/bin/bash
source ~/.localrc
privatetoken=$GLPRIVATETOKEN
username=dimitrieh
managerusername=sarrahvesselov
monofont=Menlo-Regular

> /tmp/gitlab-todo-checker-1-1.json
TPAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');
for i in $(seq 1 $TPAGES); do
  curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=100&page=$i" >> /tmp/gitlab-todo-checker-1-1.json;
done

> /tmp/gitlab-todo-checker-2-1.json
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=10" > /tmp/gitlab-todo-checker-2-1.json;

number1=$(($(cat /tmp/gitlab-todo-checker-1-1.json | /usr/local/bin/jq -rc '.[] | select(.target_type == "MergeRequest") | select(.target.assignee.username == "'$username'") | .target_url' | wc -l) + $(cat /tmp/gitlab-todo-checker-1-1.json | /usr/local/bin/jq -rc '.[] | select(.target_type == "Issue") | select(.target.assignees[].username == "'$username'") | .target_url' | wc -l)));
echo " T $number1 | templateImage=iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII=";

echo "---";
echo "Refresh | refresh=true"
echo "Your todos on GitLab | href=https://gitlab.com/dashboard/todos";
echo "Edit this file | bash=/usr/local/bin/atom param1=--add param2=/Users/dimitrie/.dotfiles/bitbar terminal=false";

echo "---";
echo "Todo's on assigned merge requests";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") !$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target_type == "MergeRequest") | select(.target.assignee.username == "'$username'") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's on design repository issues";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.project.path == "gitlab-design") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's on merge requests";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") !$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target_type == "MergeRequest") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's with milestone 10.4";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.4") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's with milestone 10.5";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.5") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's with milestone 10.6";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.6") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's with milestone 10.7";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.7") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's with label multi-file editor";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.labels[]? == "multi-file editor") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's with label web ide";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.labels[]? == "web ide") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's with label auto devops";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.labels[]? == "auto devops") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's on assigned issues ###";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") #$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target_type == "Issue") | select(.target.assignees[].username == "'$username'") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's on issues and merge requests which you have created yourself";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.author.username == "'$username'") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

# BROKEN!
# echo "---";
# echo "Todo's on issues and merge requests which you have awarded a star emoji";
# while read -r iid
#       read -r path
#       read -r project_id
#       read -r state
#       read -r title
#       read -r target_url; do
#     echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
# done < <(/usr/local/bin/jq -rc '.[] | select(.name == "star") |  | select(.user.username == "'$username'") | .target.iid,.project.path,.target.project_id,.target.state,.target.title,.target_url' < curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/projects/$project_id/issues/$iid/award_emoji");


echo "---";
echo "Todo's from your manager on issues and merge requests";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.author.username == "'$managerusername'") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "5 most recent todo's";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[range(0;10)] | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);
