#!/bin/sh
#
# Micro editor configuration
#
# Usage:
#   micro/install.sh              # Interactive mode
#   micro/install.sh --auto-install  # Automatically install if missing
#   micro/install.sh --skip-install  # Skip installation if missing

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
      echo "  --auto-install   Automatically install micro if missing"
      echo "  --skip-install   Skip installation if micro is missing"
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

# Check for micro editor
if test ! $(which micro)
then
  echo "  x Micro editor not found."
  
  if [ "$SKIP_INSTALL" == "true" ]; then
    echo "  Skipping micro configuration (--skip-install flag provided)"
    exit 0
  elif [ "$AUTO_INSTALL" == "true" ]; then
    echo "  Installing micro automatically..."
    REPLY="y"
  else
    read -p "  Install micro now? [y/N] " -n 1 -r
    echo
  fi
  
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