# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
fi

# Screen Sharing management aliases
alias screensharing-enable='sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist'
alias screensharing-disable='sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist'
alias screensharing-status='sudo launchctl list com.apple.screensharing'
