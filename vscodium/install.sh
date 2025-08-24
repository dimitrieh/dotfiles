#!/bin/sh
#
# VSCodium configuration
#
# Usage:
#   vscodium/install.sh              # Interactive mode
#   vscodium/install.sh --auto-install  # Automatically install if missing
#   vscodium/install.sh --skip-install  # Skip installation if missing

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
      echo "  --auto-install   Automatically install VSCodium if missing"
      echo "  --skip-install   Skip installation if VSCodium is missing"
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

# Check for VSCodium
if test ! $(which codium)
then
  echo "  x VSCodium CLI not found."
  
  if [ "$SKIP_INSTALL" == "true" ]; then
    echo "  Skipping VSCodium configuration (--skip-install flag provided)"
    exit 0
  elif [ "$AUTO_INSTALL" == "true" ]; then
    echo "  Installing VSCodium automatically..."
    REPLY="y"
  else
    read -p "  Install VSCodium now? [y/N] " -n 1 -r
    echo
  fi
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "  Installing VSCodium..."
    brew install --cask vscodium
    echo "  Note: You may need to enable 'codium' command: Open VSCodium > Command Palette > Shell Command: Install 'codium' command in PATH"
  else
    echo "  Skipping VSCodium configuration (VSCodium not installed)"
    exit 0
  fi
fi

# Create VSCodium User directory if it doesn't exist
mkdir -p "$HOME/Library/Application Support/VSCodium/User"

# Backup existing settings if they exist and aren't already symlinked
if [ -f "$HOME/Library/Application Support/VSCodium/User/settings.json" ] && [ ! -L "$HOME/Library/Application Support/VSCodium/User/settings.json" ]
then
  mv "$HOME/Library/Application Support/VSCodium/User/settings.json" "$HOME/Library/Application Support/VSCodium/User/settings.json.backup"
  echo "  ✓ Backed up existing VSCodium settings to settings.json.backup"
fi

# Create symlink for the settings file
ln -sf "$DOTFILES_ROOT/vscodium/settings.json" "$HOME/Library/Application Support/VSCodium/User/settings.json"

# Validate the symlink was created correctly
if [ "$(readlink "$HOME/Library/Application Support/VSCodium/User/settings.json")" = "$DOTFILES_ROOT/vscodium/settings.json" ]
then
  echo "  ✓ VSCodium configuration linked and verified"
else
  echo "  ✗ VSCodium configuration link failed"
  exit 1
fi