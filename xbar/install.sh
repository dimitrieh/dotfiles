#!/bin/sh
#
# xbar menu bar app configuration
#

# Get dotfiles root directory
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# Check for xbar
if ! brew list xbar &>/dev/null
then
  echo "  x xbar not found."
  read -p "  Install xbar now? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "  Installing xbar..."
    brew install --cask xbar
  else
    echo "  Skipping xbar configuration (xbar not installed)"
    exit 0
  fi
fi

# Create xbar directory if it doesn't exist
mkdir -p "$HOME/Library/Application Support/xbar"

# Backup existing plugins directory if it exists and isn't already symlinked
if [ -d "$HOME/Library/Application Support/xbar/plugins" ] && [ ! -L "$HOME/Library/Application Support/xbar/plugins" ]
then
  mv "$HOME/Library/Application Support/xbar/plugins" "$HOME/Library/Application Support/xbar/plugins.backup"
  echo "  ✓ Backed up existing xbar plugins to plugins.backup"
fi

# Create symlink for the entire plugins directory
ln -sf "$DOTFILES_ROOT/xbar/plugins" "$HOME/Library/Application Support/xbar/plugins"

# Validate the symlink was created correctly
if [ "$(readlink "$HOME/Library/Application Support/xbar/plugins")" = "$DOTFILES_ROOT/xbar/plugins" ]
then
  echo "  ✓ xbar plugins directory linked and verified"
  echo "    Note: You may need to refresh xbar or restart the app to see the plugins"
else
  echo "  ✗ xbar plugins directory link failed"
  exit 1
fi