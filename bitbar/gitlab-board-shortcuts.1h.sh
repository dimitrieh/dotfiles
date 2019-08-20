#!/bin/bash

export PATH=:/usr/local/bin:$PATH

# Variables
source ~/.localrc
monofont=Menlo-Regular
monosize=12
headercolor=#444444
privatetoken=$GLPRIVATETOKEN
boards="/tmp/gitlab-boards.json"
gitlabicon="iVBORw0KGgoAAAANSUhEUgAAACIAAAAgAQMAAABNQTiKAAABG2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+CiA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJyIj8+Gkqr6gAAAYJpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAACiRdZHfK4NRGMc/G/Jroka5cLE0rkxDLW6ULaGkNVOGm+3du01t8/a+k5Zb5VZR4savC/4CbpVrpYiUlDvXxA3r9by22pI9p+c8n/M953k65zlgD6eVjFHrhUw2p4cm/K75yIKr/oVGWnDSgTuqGNpYMDhNVfu8x2bFW49Vq/q5f605rhoK2BqERxVNzwlPCk+v5TSLd4TblVQ0Lnwm3KfLBYXvLD1W5FeLk0X+tlgPhwJgbxN2JSs4VsFKSs8Iy8txZ9KrSuk+1kscanZuVmK3eBcGISbw42KKcQL4GGBEZh8eBumXFVXyvb/5M6xIriKzRh6dZZKkyNEn6qpUVyUmRFdlpMlb/f/bVyMxNFis7vBD3bNpvvdA/TYUtkzz68g0C8dQ8wSX2XL+yiEMf4i+VdbcB9C6AedXZS22Cxeb0PmoRfXor1Qjbk8k4O0UWiLgvIGmxWLPSvucPEB4Xb7qGvb2oVfOty79AERNZ9aX3fKfAAAABlBMVEUAAAAmRcn2EULJAAAAAnRSTlP/AOW3MEoAAAAJcEhZcwAAFiUAABYlAUlSJPAAAABmSURBVAiZY/gPBAcYkMm////vRyV//P8vj0p+qP/Hj0o+sP/DDjfnAT+QPP+B/zOYfHyA4TiYbP4hf/AAw8Ef8s1A9T/kgbp+/LEHmvanxs4eqMvGBqR3XiWIvFcMIv/Vo7kNgwQA44R8QJN1/JwAAAAASUVORK5CYII="

# Clear JSON file
> $boards

# Get total number of todo pages if 100 todos per page
TPAGES=$(curl -i -s -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/groups/9970/boards/?per_page=100" | grep -Fi X-Total-Pages | awk '/X-Total-Pages/ { print $2 }' | tr -d '\r');

# Write todos to JSON file for each page
for i in $(seq 1 $TPAGES); do
  curl -s -L -H "PRIVATE-TOKEN: $privatetoken" "https://gitlab.com/api/v4/groups/9970/boards/?per_page=100&page=$i" >> $boards;

  # If GitLab is not responding, exit with error message
  if grep -Fq "GitLab is not responding" $boards
  then
    echo " B | templateImage=$gitlabicon";
    echo "---"
    echo "Error: GitLab is not responding"
    echo "---";
    echo "Retry | refresh=true"
    exit 1
  fi
done

# Join page arrays
jq -s 'add' $boards > /tmp/boards.tmp && mv /tmp/boards.tmp $boards

# Function to create filtered lists of todos
filter () {
  echo "---";
  echo "$1 | color=$headercolor";
  while read -r id
        read -r name
        read -r web_url;
    do echo "\
$(printf %-15.15s "${name}") | href=$web_url/-/boards/$id font=$monofont size=$monosize";
  done < <(jq -rc '.[] | select('"$2"')? | .id,.name,.group.web_url' < $boards);
}

echo " B | templateImage=$gitlabicon";
echo "---";
echo "Refresh | refresh=true";

filter 'Verify label boards' '.labels[].name == "devops::verify"'

echo "---";
echo "UX boards | color=$headercolor";
echo "UX team | font=$monofont size=$monosize href=https://gitlab.com/groups/gitlab-org/-/boards/849926";
