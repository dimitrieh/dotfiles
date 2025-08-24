#!/bin/sh
#
# Visual Studio Code configuration
#
# Usage:
#   vscode/install.sh              # Interactive mode
#   vscode/install.sh --auto-install  # Automatically install if missing
#   vscode/install.sh --skip-install  # Skip installation if missing

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
      echo "  --auto-install   Automatically install VS Code if missing"
      echo "  --skip-install   Skip installation if VS Code is missing"
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

# Check for VS Code
if test ! $(which code)
then
  echo "  x VS Code CLI not found."
  
  if [ "$SKIP_INSTALL" == "true" ]; then
    echo "  Skipping VS Code configuration (--skip-install flag provided)"
    exit 0
  elif [ "$AUTO_INSTALL" == "true" ]; then
    echo "  Installing VS Code automatically..."
    REPLY="y"
  else
    read -p "  Install VS Code now? [y/N] " -n 1 -r
    echo
  fi
  
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