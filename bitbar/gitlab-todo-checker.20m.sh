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
days=90

export PATH="$PATH:/usr/local/bin"

present=$(jq -n 'now' | awk '{print int($0)}')
daysago=$(($days * 86400))
timeago=$(($present - $daysago))

# > /tmp/gitlab-todo-checker-1-1.json
# TPAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');
# for i in $(seq 1 $TPAGES); do
#   curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=100&page=$i" | jq -rc '.[].created_at |= (sub("\\....Z";"Z") | fromdate)' >> /tmp/gitlab-todo-checker-1-1.json;
#   sed -i.bck '$s/$/,/' /tmp/gitlab-todo-checker-1-1.json;
# done
# tr '\n' ' ' < /tmp/gitlab-todo-checker-1-1.json > /tmp/blubtmp.json;
cat /tmp/blubtmp.json > /tmp/gitlab-todo-checker-1-1.json;
perl -pi -e 's/\], \[/,/g' /tmp/gitlab-todo-checker-1-1.json;
/usr/local/bin/sed -i '$ s/..$//' /tmp/gitlab-todo-checker-1-1.json;

> /tmp/gitlab-todo-checker-2-1.json
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=10" > /tmp/gitlab-todo-checker-2-1.json;

# Count all todos on merge request and issues with $speciallabel
number1=$(($(cat /tmp/gitlab-todo-checker-1-1.json | jq -rc '.[] | select(.target_type == "MergeRequest") | .target_url' | wc -l) + $(cat /tmp/gitlab-todo-checker-1-1.json | jq -rc '.[] | select(.target_type == "Issue") | select(.target.assignees[].username == "'$username'") | select(.target.labels[]? == "'$speciallabel'") | .target_url' | wc -l)));
echo " T $number1 | templateImage=iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII=";

echo "---";
echo "Refresh | refresh=true"
echo "Your todos on GitLab | href=https://gitlab.com/dashboard/todos";
echo "Edit this file | bash=code param1=--add param2=/Users/dimitrie/.dotfiles/bitbar terminal=false";
echo $timeago

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
file=/tmp/gitlab-todo-checker-1-epics.txt
> $file
echo "Todo's on epics | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
while read -r iid
      read -r path
      read -r state
      read -r labels
      read -r title
      read -r target_url; do
    echo "\
$(printf %-15.15s "$path")\
$(echo '&')\
$(printf '%-6s' "$iid")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf '%-2.2s' "$(echo ${labels} | jq '.[]? | select(. == "'$speciallabel2'")' | sed 's/"//g' | sed 's/^\(.\).*/\1/')")\
$(printf %-75.75s "$([[ $state == *'pending'* ]] && echo '' || echo "("$state") ")$title")\
| href=$target_url font=$monofont";
echo $target_url >> $file;
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target_type == "Epic") | .target.iid,.group.path,.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.project.path == "gitlab-design") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.project.path == "design.gitlab.com") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

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
file=/tmp/gitlab-todo-checker-1-milestone-11-6.txt
> $file
echo "Todo's with milestone 11.6 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.milestone.title == "11.6") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-11-7.txt
> $file
echo "Todo's with milestone 11.7 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.milestone.title == "11.7") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-11-8.txt
> $file
echo "Todo's with milestone 11.8 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.milestone.title == "11.8") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-12-0.txt
> $file
echo "Todo's with milestone 12.0 | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.milestone.title == "12.0") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-jason.txt
> $file
echo "Todo's from Jason | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.author.username == "jlenny") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-bugs.txt
> $file
echo "Todo's from bugs | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.labels[]? == "bug") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-customer.txt
> $file
echo "Todo's from customer requested issues | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.labels[]? == "customer") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.author.username == "'$managerusername'") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-next-3-4.txt
> $file
echo "Todo's with milestone next 3-4 releases | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.milestone.title == "Next 3-4 releases") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-next-4-7.txt
> $file
echo "Todo's with milestone next 4-7 releases | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.milestone.title == "Next 4-7 releases") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-next-7-13.txt
> $file
echo "Todo's with milestone next 7-13 releases | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.milestone.title == "Next 7-13 releases") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-milestone-backlog.txt
> $file
echo "Todo's with milestone Backlog | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.milestone.title == "Backlog") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-rayana.txt
> $file
echo "Todo's from Rayana | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.author.username == "rverissimo") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);


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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target_type == "Issue") | select(.target.assignees[].username == "'$username'") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

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
done < <(jq -rc '.[] | select(.created_at >  '$timeago') | select(.target.author.username == "'$username'") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-snv.txt
> $file
echo "Todo's for SNV | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.project.path_with_namespace | contains("stichtingnatuurlijkverder"))? | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
file=/tmp/gitlab-todo-checker-1-divine.txt
> $file
echo "Todo's for Divine Home | bash=/Users/dimitrie/.dotfiles/bin/openlist param1=$file terminal=false color=$headercolor";
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
done < <(jq -rc '.[] | select(.project.path == "divine-home") | .target.iid,.project.path,.target.state,.target.labels,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

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
