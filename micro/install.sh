#!/bin/sh
#
# Micro editor configuration
#

# Get dotfiles root directory
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# Check for micro editor
if test ! $(which micro)
then
  echo "  x Micro editor not found."
  read -p "  Install micro now? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "  Installing micro..."
    brew install micro
  else
    echo "  Skipping micro configuration (micro not installed)"
    exit 0
  fi
fi

# Create micro colorschemes directory if it doesn't exist
mkdir -p "$HOME/.config/micro/colorschemes"

# Create symlink for the color theme
ln -sf "$DOTFILES_ROOT/micro/pcs-tc.micro" "$HOME/.config/micro/colorschemes/pcs-tc.micro"

# Validate the symlink was created correctly
if [ "$(readlink "$HOME/.config/micro/colorschemes/pcs-tc.micro")" = "$DOTFILES_ROOT/micro/pcs-tc.micro" ]
then
  echo "  ✓ Micro editor configuration linked and verified"
else
  echo "  ✗ Micro editor configuration link failed"
  exit 1
fi