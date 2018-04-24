#!/bin/bash
source ~/.localrc
privatetoken=$GLPRIVATETOKEN
username=dimitrieh
managerusername=sarrahvesselov
monofont=Menlo-Regular
speciallabel=Deliverable
speciallabel2=UX
speciallabelimg=Ⓓ
headercolor=#444444

export PATH="$PATH:/usr/local/bin"

> /tmp/gitlab-todo-checker-1-1.json
TPAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');
for i in $(seq 1 $TPAGES); do
  curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=100&page=$i" >> /tmp/gitlab-todo-checker-1-1.json;
done

> /tmp/gitlab-todo-checker-2-1.json
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=10" > /tmp/gitlab-todo-checker-2-1.json;

# Count all todos on merge request and issues with $speciallabel
number1=$(($(cat /tmp/gitlab-todo-checker-1-1.json | jq -rc '.[] | select(.target_type == "MergeRequest") | .target_url' | wc -l) + $(cat /tmp/gitlab-todo-checker-1-1.json | jq -rc '.[] | select(.target_type == "Issue") | select(.target.assignees[].username == "'$username'") | select(.target.labels[]? == "'$speciallabel'") | .target_url' | wc -l)));
echo " T $number1 | templateImage=iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII=";

echo "---";
echo "Refresh | refresh=true"
echo "Your todos on GitLab | href=https://gitlab.com/dashboard/todos";
echo "Edit this file | bash=atom param1=--add param2=/Users/dimitrie/.dotfiles/bitbar terminal=false";

echo "---";
file=/tmp/gitlab-todo-checker-1-assigned-merge-requests.txt
> $file
echo "Todo's on assigned merge requests | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target_type == "MergeRequest") | select(.target.assignee.username == "'$username'") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-design-repo-issues.txt
> $file
echo "Todo's on design repository issues | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.project.path == "gitlab-design") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-design-gitlab-com-issues.txt
> $file
echo "Todo's on design.gitlab.com repository issues | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.project.path == "design.gitlab.com") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-vision.txt
> $file
echo "Todo's with label vision | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target.labels[]? == "vision") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-merge-requests.txt
> $file
echo "Todo's on merge requests | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target_type == "MergeRequest") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-10-7.txt
> $file
echo "Todo's with milestone 10.7 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target.milestone.title == "10.7") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-10-8.txt
> $file
echo "Todo's with milestone 10.8 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target.milestone.title == "10.8") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-11-0.txt
> $file
echo "Todo's with milestone 11.0 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target.milestone.title == "11.0") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);


echo "---";
file=/tmp/gitlab-todo-checker-1-web-ide.txt
> $file
echo "Todo's with label web ide | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target.labels[]? == "web ide") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-assigned-issues.txt
> $file
echo "Todo's on your assigned issues | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target_type == "Issue") | select(.target.assignees[].username == "'$username'") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-created-yourself.txt
> $file
echo "Todo's on issues and merge requests which you have created yourself | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.target.author.username == "'$username'") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-manager.txt
> $file
echo "Todo's from your manager on issues and merge requests | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.author.username == "'$managerusername'") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-filipa.txt
> $file
echo "Todo's from filipa | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.author.username == "filipa") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-recent.txt
> $file
echo "10 most recent todo's | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[range(0;10)] | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);
