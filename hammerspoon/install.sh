#!/bin/sh
#
# Hammerspoon configuration
#
# Usage:
#   hammerspoon/install.sh              # Interactive mode
#   hammerspoon/install.sh --auto-install  # Automatically install if missing
#   hammerspoon/install.sh --skip-install  # Skip installation if missing

# Parse command line arguments
AUTO_INSTALL=false
SKIP_INSTALL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --auto-install)
      AUTO_INSTALL=true
      shift
      ;;
    --skip-install)
      SKIP_INSTALL=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --auto-install   Automatically install Hammerspoon if missing"
      echo "  --skip-install   Skip installation if Hammerspoon is missing"
      echo "  --help, -h       Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Get dotfiles root directory
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# Check for Hammerspoon (it's a GUI app, so check for the app bundle or hs CLI)
if [ ! -d "/Applications/Hammerspoon.app" ] && test ! $(which hs)
then
  echo "  x Hammerspoon not found."

  if [ "$SKIP_INSTALL" == "true" ]; then
    echo "  Skipping Hammerspoon configuration (--skip-install flag provided)"
    exit 0
  elif [ "$AUTO_INSTALL" == "true" ]; then
    echo "  Installing Hammerspoon automatically..."
    REPLY="y"
  else
    read -p "  Install Hammerspoon now? [y/N] " -n 1 -r
    echo
  fi

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "  Installing Hammerspoon..."
    brew install --cask hammerspoon
  else
    echo "  Skipping Hammerspoon configuration (Hammerspoon not installed)"
    exit 0
  fi
fi

# Create hammerspoon config directory if it doesn't exist
mkdir -p "$HOME/.hammerspoon"

# Create symlink for the init.lua file
ln -sf "$DOTFILES_ROOT/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"

# Validate the symlink was created correctly
if [ "$(readlink "$HOME/.hammerspoon/init.lua")" = "$DOTFILES_ROOT/hammerspoon/init.lua" ]
then
  echo "  ✓ Hammerspoon configuration linked and verified"
else
  echo "  ✗ Hammerspoon configuration link failed"
  exit 1
fi
