#!/bin/sh
#
# xbar menu bar app configuration
#
# Usage:
#   xbar/install.sh              # Interactive mode
#   xbar/install.sh --auto-install  # Automatically install if missing
#   xbar/install.sh --skip-install  # Skip installation if missing

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
      echo "  --auto-install   Automatically install xbar if missing"
      echo "  --skip-install   Skip installation if xbar is missing"
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

# Check for xbar
if ! brew list xbar &>/dev/null
then
  echo "  x xbar not found."
  
  if [ "$SKIP_INSTALL" == "true" ]; then
    echo "  Skipping xbar configuration (--skip-install flag provided)"
    exit 0
  elif [ "$AUTO_INSTALL" == "true" ]; then
    echo "  Installing xbar automatically..."
    REPLY="y"
  else
    read -p "  Install xbar now? [y/N] " -n 1 -r
    echo
  fi
  
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