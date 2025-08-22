#!/bin/sh
#
# Visual Studio Code configuration
#

# Get dotfiles root directory
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# Check for VS Code
if test ! $(which code)
then
  echo "  x VS Code CLI not found."
  read -p "  Install VS Code now? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "  Installing VS Code..."
    brew install --cask visual-studio-code
    echo "  Note: You may need to enable 'code' command: Open VS Code > Command Palette > Shell Command: Install 'code' command in PATH"
  else
    echo "  Skipping VS Code configuration (VS Code not installed)"
    exit 0
  fi
fi

# Create VS Code User directory if it doesn't exist
mkdir -p "$HOME/Library/Application Support/Code/User"

# Backup existing settings if they exist and aren't already symlinked
if [ -f "$HOME/Library/Application Support/Code/User/settings.json" ] && [ ! -L "$HOME/Library/Application Support/Code/User/settings.json" ]
then
  mv "$HOME/Library/Application Support/Code/User/settings.json" "$HOME/Library/Application Support/Code/User/settings.json.backup"
  echo "  ✓ Backed up existing VS Code settings to settings.json.backup"
fi

# Create symlink for the settings file
ln -sf "$DOTFILES_ROOT/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

# Validate the symlink was created correctly
if [ "$(readlink "$HOME/Library/Application Support/Code/User/settings.json")" = "$DOTFILES_ROOT/vscode/settings.json" ]
then
  echo "  ✓ VS Code configuration linked and verified"
else
  echo "  ✗ VS Code configuration link failed"
  exit 1
fi