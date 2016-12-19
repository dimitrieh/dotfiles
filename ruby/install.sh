#!/bin/sh
#
# Install Ruby Version Manager
#
###############################################################################
# Check for required tool                                                     #
###############################################################################

# Check for RVM
if test ! $(which rvm)
then
  echo "  x You should probably install RVM (Ruby Version Manager) first:"
  echo "    curl -L https://get.rvm.io | bash -s stable --ruby"
  echo "    Restart your shell after it's done and test with ruby --version"
  echo "    If you want to use/install a specific version use:"
  echo "    rvm install ruby-X.X.X"
  echo "    rvm --default use ruby-X.X.X"
  echo "    Once RVM is installed you can install your favorite packages:"
  exit
fi

# To update RVM

rvm get stable

# To update RubyGems

gem update --system
