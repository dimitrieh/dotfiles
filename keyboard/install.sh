#!/bin/sh
#
# Keyboard screenshot git hook setup
#

# Get dotfiles root directory
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# Check for ImageMagick
if ! command -v magick >/dev/null 2>&1
then
  echo "  x ImageMagick not found. Install it first:"
  echo "    brew install imagemagick"
  exit 1
fi

# Check for Chrome (either Google Chrome or Chromium)
if [ ! -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ] && [ ! -f "/Applications/Chromium.app/Contents/MacOS/Chromium" ]
then
  echo "  x Chrome not found. Install Google Chrome or Chromium first"
  exit 1
fi

# Check for Raycast (optional - for show-keyboard-shortcuts.sh)
if [ ! -d "/Applications/Raycast.app" ]
then
  echo "  ⚠ Raycast not found. The show-keyboard-shortcuts script won't work without it"
  echo "    brew install --cask raycast"
fi

# Check for CleanShot X (optional - for show-keyboard-shortcuts.sh)
if [ ! -d "/Applications/CleanShot X.app" ]
then
  echo "  ⚠ CleanShot X not found. The show-keyboard-shortcuts script won't work without it"
  echo "    brew install --cask cleanshot"
fi

# Create symlink for pre-commit hook
ln -sf "$DOTFILES_ROOT/keyboard/hooks/pre-commit" "$DOTFILES_ROOT/.git/hooks/pre-commit"

# Create symlink for Raycast script in the raycast directory
mkdir -p "$DOTFILES_ROOT/raycast"
ln -sf "$DOTFILES_ROOT/keyboard/show-keyboard-shortcuts.sh" "$DOTFILES_ROOT/raycast/show-keyboard-shortcuts.sh"

# Validate the symlinks were created correctly
if [ "$(readlink "$DOTFILES_ROOT/.git/hooks/pre-commit")" = "$DOTFILES_ROOT/keyboard/hooks/pre-commit" ]
then
  echo "  ✓ Keyboard screenshot pre-commit hook installed and verified"
else
  echo "  ✗ Failed to install keyboard pre-commit hook"
  exit 1
fi

if [ "$(readlink "$DOTFILES_ROOT/raycast/show-keyboard-shortcuts.sh")" = "$DOTFILES_ROOT/keyboard/show-keyboard-shortcuts.sh" ]
then
  echo "  ✓ Raycast keyboard shortcuts script linked and verified"
else
  echo "  ✗ Failed to link Raycast keyboard shortcuts script"
  exit 1
fi