#!/bin/bash
source ~/.localrc
privatetoken=$GLPRIVATETOKEN
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/?type=MergeRequest" -o /tmp/gitlab-todo-checker-1-1.json
curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/todos/" -o /tmp/gitlab-todo-checker-2-1.json
number1=$(cat /tmp/gitlab-todo-checker-2-1.json | /usr/local/bin/jq -r '.[] | select(.target.assignee.username == "dimitrieh") | .target_url' | wc -l);
echo " $number1 | templateImage=iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII=";
echo "---";
echo "Todo's on assigned Merge Requests"
while read -r iid
      read -r path
      read -r title
      read -r target_url; do
    echo "!$(printf '%-6s' "$iid") $(printf %-15.15s "$path") $(printf %-75.75s "$title") | href=$target_url font=SFMono-Regular"
done < <(/usr/local/bin/jq -rc '.[]  | select(.target.assignee.username == "dimitrieh") | select(.target_type == "MergeRequest") |.target.iid,.project.path,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json)
echo "---"
echo "Todo's on assigned Issues"
while read -r iid
      read -r path
      read -r title
      read -r target_url; do
    echo "#$(printf '%-6s' "$iid") $(printf %-15.15s "$path") $(printf %-75.75s "$title") | href=$target_url font=SFMono-Regular"
done < <(/usr/local/bin/jq -rc '.[]  | select(.target.assignee.username == "dimitrieh") | select(.target_type == "Issue") |.target.iid,.project.path,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json)
echo "---";
echo "Todo's on Merge Requests"
while read -r iid
      read -r path
      read -r title
      read -r target_url; do
    echo "!$(printf '%-6s' "$iid") $(printf %-15.15s "$path") $(printf %-75.75s "$title") | href=$target_url font=SFMono-Regular"
done < <(/usr/local/bin/jq -rc '.[] | .target.iid,.project.path,.target.title,.target_url' < /tmp/gitlab-todo-checker-1-1.json)
echo "---"
echo "Todo's with milestone 10.0"
while read -r iid
      read -r path
      read -r title
      read -r target_url; do
    echo "#$(printf '%-6s' "$iid") $(printf %-15.15s "$path") $(printf %-75.75s "$title") | href=$target_url font=SFMono-Regular"
done < <(/usr/local/bin/jq -rc '.[]  | select(.target.milestone.title == "10.0") |.target.iid,.project.path,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json)
echo "---"
echo "Todo's with milestone 10.1"
while read -r iid
      read -r path
      read -r title
      read -r target_url; do
    echo "#$(printf '%-6s' "$iid") $(printf %-15.15s "$path") $(printf %-75.75s "$title") | href=$target_url font=SFMono-Regular"
done < <(/usr/local/bin/jq -rc '.[]  | select(.target.milestone.title == "10.1") |.target.iid,.project.path,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json)
echo "---"
echo "Todo's with milestone 10.2"
while read -r iid
      read -r path
      read -r title
      read -r target_url; do
    echo "#$(printf '%-6s' "$iid") $(printf %-15.15s "$path") $(printf %-75.75s "$title") | href=$target_url font=SFMono-Regular"
done < <(/usr/local/bin/jq -rc '.[]  | select(.target.milestone.title == "10.2") |.target.iid,.project.path,.target.title,.target_url' < /tmp/gitlab-todo-checker-2-1.json)
