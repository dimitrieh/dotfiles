#!/bin/sh
#
# Install Ruby Version Manager
#
###############################################################################
# Check for required tool                                                     #
###############################################################################

# Check for rbenv
if test ! $(which rbenv)
then
  echo "  x You should probably install rbenv (Ruby Version Manager) first:"
  echo "    brew install rbenv"
  echo "    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash"
  echo "    rbenv install RUBY_VERSION"
  echo "    rbenv local RUBY_VERSION"
  echo "    Restart your shell after it's done and test with ruby --version"
  echo "    gem install bundler"
  echo "    Further instructions on https://github.com/rbenv/rbenv"
  exit
fi

# To update RubyGems

gem update --system
