#!/bin/sh
#
# Ghostty terminal configuration
#
# Usage:
#   ghostty/install.sh              # Interactive mode
#   ghostty/install.sh --auto-install  # Automatically install if missing
#   ghostty/install.sh --skip-install  # Skip installation if missing

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
      echo "  --auto-install   Automatically install Ghostty if missing"
      echo "  --skip-install   Skip installation if Ghostty is missing"
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

# Check for Ghostty
if test ! $(which ghostty)
then
  echo "  x Ghostty not found."
  
  if [ "$SKIP_INSTALL" == "true" ]; then
    echo "  Skipping Ghostty configuration (--skip-install flag provided)"
    exit 0
  elif [ "$AUTO_INSTALL" == "true" ]; then
    echo "  Installing Ghostty automatically..."
    REPLY="y"
  else
    read -p "  Install Ghostty now? [y/N] " -n 1 -r
    echo
  fi
  
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