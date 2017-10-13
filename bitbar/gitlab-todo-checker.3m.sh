#!/bin/bash
source ~/.localrc
privatetoken=$GLPRIVATETOKEN
username=dimitrieh
managerusername=sarrahvesselov
monofont=Menlo-Regular
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?type=MergeRequest" -o /tmp/gitlab-todo-checker-1-1.json;
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?type=Issue" -o /tmp/gitlab-todo-checker-3-1.json;
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?per_page=1000" -o /tmp/gitlab-todo-checker-2-1.json;
number1=$(($(cat /tmp/gitlab-todo-checker-1-1.json | /usr/local/bin/jq -rc '.[] | select(.target.assignee.username == "'$username'") | .target_url' | wc -l) + $(cat /tmp/gitlab-todo-checker-3-1.json | /usr/local/bin/jq -rc '.[] | select(.target.assignees[].username == "'$username'") | .target_url' | wc -l)));
echo " $number1 | templateImage=iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII=";

echo "---";
echo "Todo's on assigned merge requests";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") !$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[]  | select(.target.assignee.username == "'$username'") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's on assigned issues";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") #$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[]  | select(.target.assignees[].username == "'$username'") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-3-1.json);

echo "---";
echo "Todo's on merge requests";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") !$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json);

echo "---";
echo "Todo's with milestone 10.0";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.0") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "Todo's with milestone 10.1";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.1") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "Todo's with milestone 10.2";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.2") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "Todo's with milestone 10.3";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.3") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "Todo's with milestone 10.4";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.milestone.title == "10.4") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "Todo's with label Portfolio Management";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.labels[]? == "portfolio management") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "Todo's with label Auto DevOps";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.labels[]? == "auto devops") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "Todo's on issues and merge requests which you have created yourself";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.target.author.username == "'$username'") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "Todo's from your manager on issues and merge requests";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[] | select(.author.username == "'$managerusername'") | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);

echo "---";
echo "5 most recent todo's";
while read -r iid
      read -r path
      read -r state
      read -r title
      read -r target_url; do
    echo "$(printf %-15.15s "$path") $([[ $target_url == *'merge_requests'* ]] && echo '!' || echo '#')$(printf '%-6s' "$iid") $(printf %-75.75s "$([[ $state == *'opened'* ]] && echo '' || echo "("$state") ")$title") | href=$target_url font=$monofont"
done < <(/usr/local/bin/jq -rc '.[range(0;5)] | .target.iid,.project.path,.target.state,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json);
