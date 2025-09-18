#!/usr/bin/env bash
#
# <xbar.title>SSH Status</xbar.title>
# <xbar.version>v0.1.0</xbar.version>
# <xbar.author>Olivier Tille</xbar.author>
# <xbar.author.github>oliviernt</xbar.author.github>
# <xbar.image>http://i.imgur.com/s8FMCLG.png</xbar.image>
# <xbar.desc>Continuously checks if hosts are available for ssh connection</xbar.desc>
# <xbar.dependencies>Bash</xbar.dependencies>
#
# SSH Status plugin
# by Olivier Tille (@oliviernt)
#
# Continuously checks if hosts are available for ssh connection on port 22
HOSTS=("dimitries-mac-mini")
head="ssh status"
body=""
errors=0
for host in "${HOSTS[@]}"; do
  if nc -z -G 2 "$host" 22 &> /dev/null; then
    body="$body\n🟢 $host is up | bash=ssh param1=$host"
  else
    body="$body\n🔻 $host looks down from here | bash=ssh param1=$host"
    errors=$((errors + 1))
  fi
  body="$body\n---"
done

echo -n "$head"
[ "$errors" -eq 0 ] || echo -n " ($((${#HOSTS[@]} - errors))/${#HOSTS[@]}) | color=red"
echo -e "\n---"
echo -e "$body"
