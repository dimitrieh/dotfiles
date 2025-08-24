#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."

  # Install the correct homebrew for each OS type
  if test "$(uname)" = "Darwin"
  then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install)"
  elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
  then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install)"
  fi

fi

# Get dotfiles root directory
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# Check for workstation flag
INSTALL_WORKSTATION=false
if [[ "$1" == "--workstation" ]]; then
  INSTALL_WORKSTATION=true
  echo "Installing workstation packages..."
fi

# Always install essential packages
echo "› brew bundle (essentials)"
brew bundle --file="$DOTFILES_ROOT/homebrew/Brewfile.essentials"

# Install workstation packages if requested
if [ "$INSTALL_WORKSTATION" = true ]; then
  echo "› brew bundle (workstation)"
  brew bundle --file="$DOTFILES_ROOT/homebrew/Brewfile.workstation"
fi

brew update && brew upgrade && brew cleanup && brew doctor

exit 0
