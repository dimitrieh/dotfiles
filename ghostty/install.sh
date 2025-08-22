#!/bin/sh
#
# Ghostty terminal configuration
#

# Get dotfiles root directory
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# Check for Ghostty
if test ! $(which ghostty)
then
  echo "  x Ghostty not found."
  read -p "  Install Ghostty now? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "  Installing Ghostty..."
    brew install ghostty
  else
    echo "  Skipping Ghostty configuration (Ghostty not installed)"
    exit 0
  fi
fi

# Create ghostty config directory if it doesn't exist (macOS specific path)
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"

# Create symlink for the config file
ln -sf "$DOTFILES_ROOT/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# Validate the symlink was created correctly
if [ "$(readlink "$HOME/Library/Application Support/com.mitchellh.ghostty/config")" = "$DOTFILES_ROOT/ghostty/config" ]
then
  echo "  ✓ Ghostty configuration linked and verified"
else
  echo "  ✗ Ghostty configuration link failed"
  exit 1
fi