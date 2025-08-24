alias reload!='. ~/.zshrc'

# Improved cat command - prefer bat over ccat
if command -v bat > /dev/null 2>&1; then
  alias cat=bat
elif command -v ccat > /dev/null 2>&1; then
  alias cat=ccat
fi

# Improved find command - use fd when available
if command -v fd > /dev/null 2>&1; then
  # Fast file search
  alias ff='fd'
  # Find by filename pattern (case insensitive)
  alias ffi='fd -i'
  # Find files only (no directories)
  alias ffile='fd -t f'
  # Find directories only
  alias fdir='fd -t d'
fi

# Improved grep command - use ripgrep when available
if command -v rg > /dev/null 2>&1; then
  # Fast grep replacement
  alias rgg='rg'
  # Case insensitive search
  alias rggi='rg -i'
  # Search with line numbers (default for rg)
  alias rggn='rg -n'
  # Search in specific file types
  alias rgjs='rg -t js'
  alias rgpy='rg -t py'
  alias rgmd='rg -t md'
  # Search with context (3 lines before/after)
  alias rggc='rg -C 3'
fi


# Show all environment variables (also from .localrc)
alias senv="printenv"

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias cdb='cd -'
alias c='clear'
alias cls='clear;ls'
alias h="history"
alias v="vim"

alias e="$EDITOR"

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

# List Files & Folders better
if command -v eza > /dev/null 2>&1; then
  alias list='eza --long --header --git -a' # Uses eza which also lists git
else
  alias list='ls -la'
fi
alias la="ls -aF"
alias ld="ls -ld"
alias ll="ls -l"
alias lt='ls -At1 && echo "------Oldest--"'
alias ltr='ls -Art1 && echo "------Newest--"'

# Always enable colors for tree
alias tree='tree -C'

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Redoes the last command and copies the output to clipboard
alias cl="fc -e -|pbcopy"

# Copies the output of the last command with out re-executing it
    # http://stackoverflow.com/questions/5130968/how-can-i-copy-the-output-of-a-command-directly-into-my-clipboard

# Copy the working directory path
alias cpwd='pwd|tr -d "\n"|pbcopy'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip2="curl icanhazip.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# Ping
alias pr='ping -c 1 192.168.1.1 | tail -3'
alias pg='ping -c 1 google.com | tail -3'

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Hide or show all desktop icons, except those in finder preferences
# Psst This doesn't work when hidden files are shown
alias hidedesktop="chflags hidden ~/Desktop/* & hidef"
alias showdesktop="chflags nohidden ~/Desktop/*"

# Show/hide hidden files in Finder
alias showf="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidef="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# URL-encode strings
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'

# Imgur uploader | https://github.com/kevva/imgur-uploader-cli
alias imgur="imgur-uploader"

# Website download for local access (including all of the JavaScript CSS and images + convert links)
alias wgetwebsite="wget -mpk "

# Edit hosts file
alias hostsfile="sudo micro /private/etc/hosts"
alias reloadhostsfile="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder"

# Automatically start Python server at current directory
alias lserve="php -S localhost:3333"

alias vlc="/Applications/VLC.app/Contents/MacOS/VLC"
alias yt="mpsyt"

alias gfupdate="curl https://raw.githubusercontent.com/qrpike/Web-Font-Load/master/install.sh | sh"

alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 7'"

# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

alias incolumns="column -t"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

alias lorem="python ~/.dotfiles/zsh/functions/lorem "

# Hide show desktop icons
alias hidedesk='defaults write com.apple.finder CreateDesktop -bool false; killall Finder;'
alias showdesk='defaults write com.apple.finder CreateDesktop -bool true; killall Finder;'

# Chrome
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

# Tailscale
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
