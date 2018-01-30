# Sets reasonable OS X defaults.
#
# Or, in other words, set shit how I like in OS X.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.osx
#
# Run ./set-defaults.sh and you'll be good to go.
#
# Find current settings with "defaults find [name]"

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Reduce transparency in OS X.
# defaults write com.apple.universalaccess reduceTransparency -boolean true

# scrolling column views
defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0

# Disable animations when opening and closing windows
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable animations when opening a Quick Look window
defaults write -g QLPanelAnimationDuration -float 0

# Accelerated playback when adjusting the window size (Cocoa applications)
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Add a message to the login screen
# sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Your Message"

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# IOS Chime Battery Sound
defaults write com.apple.PowerChime ChimeOnAllHardware -bool true; open /System/Library/CoreServices/PowerChime.app

# Make Crash Reporter appear as a notification
defaults write com.apple.CrashReporter UseUNC 1

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Allow hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Hide Safari's bookmark bar.
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Set up Safari for development.
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

# Allow installing user scripts via GitHub or Userscripts.org
defaults write com.google.Chrome ExtensionInstallSources -array "https://*.github.com/*" "http://userscripts.org/*"
defaults write com.google.Chrome.canary ExtensionInstallSources -array "https://*.github.com/*" "http://userscripts.org/*"

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Enable press-and-hold for keys in favor of key repeat. Change this to false to favor repeat
defaults write -g ApplePressAndHoldEnabled -bool true
# Set a really fast key repeat. Uncomment this when key repeat is enabled
# defaults write NSGlobalDomain KeyRepeat -int 0

# Automatically illuminate built-in MacBook keyboard in low light
defaults write com.apple.BezelServices kDim -bool true
# Turn off keyboard illumination when computer is not used for 5 minutes
defaults write com.apple.BezelServices kDimTime -int 300

# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Enable text replacement across all applications
defaults write -g WebAutomaticTextReplacementEnabled -bool true

###############################################################################
# Time Machine                                                                #
###############################################################################
# Show any old network drive in the Time Machine interface | http://www.howtogeek.com/216077/how-to-perform-time-machine-backups-over-the-network/
# Warning network drives could result in corrupted backups
defaults write com.apple.systempreferences TMShowUnsupportedNetworkVolumes 1

# Prevent Time Machine from prompting to use new hard drives as backup volume
#defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable local Time Machine backups
#hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# Screen                                                                      #
###############################################################################

# Save screenshots to downloads
defaults write com.apple.screencapture location -string "$HOME/downloads"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

###############################################################################
# Dock, Dashboard, Launchpad, Mission Control & hot corners                   #
###############################################################################

# Minimize windows into their application icon.
# defaults write com.apple.dock minimize-to-application -boolean true

# Always prefer tabs to windows when opening documents
defaults write NSGlobalDomain AppleWindowTabbingMode -string "always"


# Change the layout (rows and columns) of Launchpad
defaults write com.apple.dock springboard-columns -int 9
defaults write com.apple.dock springboard-rows -int 4
defaults write com.apple.dock ResetLaunchPad -bool true

# Disable automatically rearrange Spaces based on recent use
# defaults write com.apple.dock mru-spaces -bool false

# Enable a really nice looking list view in stacks complete with icons and a scroll bar.
defaults write com.apple.dock use-new-list-stack -bool YES

# Sets the dock to the right of the screen
defaults write com.apple.dock orientation right

# Make icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Deactivate dashboard
defaults write com.apple.dashboard mcx-disabled -boolean true

# Disable bouncing dock icons
defaults write com.apple.dock no-bouncing -bool true

# Enables Autohide dock to be fast and easy.
defaults write com.apple.Dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.24

# Disable animations when you open an application from the Dock
defaults write com.apple.dock launchanim -bool false

# Autohide the dock
defaults write com.apple.dock autohide -bool YES

# Set the right size of dock icons
defaults write com.apple.dock tilesize -integer 45

# Turn off magnification
defaults delete com.apple.dock magnification

# Make all animations faster that are used by Mission Control
defaults write com.apple.dock expose-animation-duration -float 0.1

killall Dock

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# Top left screen corner → Launchpad
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → Mission Control
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → Put display to sleep
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
# Bottom right screen corner → Desktop
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# Finder                                                                      #
###############################################################################

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Turn on extensions in Finder and file dialogs
defaults write -g AppleShowAllExtensions -bool YES

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Use AirDrop over every interface. srsly this should be a default.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Always open everything in Finder's list view. This is important.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

# Disable animation when opening the Info window in OS X Finder (cmd⌘ + i)
defaults write com.apple.finder DisableAllAnimations -bool true

killall Finder

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Transmission.app                                                            #
###############################################################################

# Use `~/Documents/Torrents` to store incomplete downloads
# defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
# defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"

# Don’t prompt for confirmation before downloading
defaults write org.m0k.transmission DownloadAsk -bool false

# Trash original torrent files
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

# Hide the donate message
defaults write org.m0k.transmission WarningDonate -bool false
# Hide the legal disclaimer
defaults write org.m0k.transmission WarningLegal -bool false

###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# Enable Debug Menu in the Mac App Store
defaults write com.apple.appstore ShowDebugMenu -bool true

###############################################################################
# Keyboard Shortcuts                                                          #
###############################################################################

# http://hints.macworld.com/article.php?story=20131123074223584
# @ for Command, $ for Shift, ~ for Alt and ^ for Ctrl
defaults write -g NSUserKeyEquivalents '{
"Enter Full Screen"="@~^$f";
"Exit Full Screen"="@~^$f";
"Enter Full Screen Mode"="@~^$f";
"Exit Full Screen Mode"="@~^$f";
"Toggle Full Screen"="@~^$f";
"Full Screen"="@~^$f";
"Fullscreen"="@~^$f";
"Normal Screen"="@~^$f";
"Remove Full Screen"="@~^$f";
}'

echo "Done. Do a restart to let all changes take effect ;)"
