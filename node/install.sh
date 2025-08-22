#!/bin/sh
#
# Install command-line tools using Node Package Manager NPM
#
###############################################################################
# Check for required tool                                                     #
###############################################################################

# Check for Nodejs
if test ! $(which node)
then
  echo "  x Node.js not found. Install it first:"
  echo "    brew install node"
  exit
fi

# Check for npm (should be installed with node)
if test ! $(which npm)
then
  echo "  x npm not found. It should come with Node.js"
  echo "    brew install node"
  exit
fi

###############################################################################
# Install packages                                                            #
###############################################################################

# Easily spoof your MAC address in OS X & Linux | https://github.com/feross/SpoofMAC
if test ! $(which spoof)
then
  npm install spoof -g
fi

# Get the path to an app (OS X) | https://github.com/sindresorhus/app-path-cli
if test ! $(which app-path)
then
  npm install -g app-path-cli
fi

# Get current battery level | https://github.com/gillstrom/battery-level
if test ! $(which battery-level)
then
  npm install -g battery-level
fi

# A package manager for the web | http://bower.io/
if test ! $(which bower)
then
  npm install -g bower
fi

# Change the screen brightness | https://github.com/kevva/brightness-cli
if test ! $(which brightness)
then
  npm install -g brightness-cli
fi

# Time-saving synchronised browser testing | https://www.browsersync.io/
if test ! $(which browser-sync)
then
  npm install -g browser-sync
fi

# Castnow is a command-line utility that can be used to play back media files on your Chromecast device | https://github.com/xat/castnow
if test ! $(which castnow)
then
  npm install -g castnow
fi

# Cast local media to your TV through UPnP/DLNA | https://github.com/xat/dlnacast
if test ! $(which dlnacast)
then
  npm install -g dlnacast
fi

# Terminal string styling done right | https://github.com/chalk/chalk-cli
if test ! $(which chalk)
then
  npm install -g chalk-cli
fi

# Copy files | https://github.com/sindresorhus/cpy-cli
if test ! $(which cpy)
then
  npm install -g cpy-cli
fi

# Delete files and folders | https://github.com/sindresorhus/del-cli
if test ! $(which de)
then
  npm install -g del-cli
fi

# Empty the trash | https://github.com/sindresorhus/empty-trash-cli
if test ! $(which empty-trash)
then
  npm install -g empty-trash-cli
fi

# Find a file by walking up parent directories | https://github.com/sindresorhus/find-up-cli
if test ! $(which find-up)
then
  npm install -g find-up-cli
fi

# The JavaScript Task Runner | http://gruntjs.com/
if test ! $(which grunt)
then
  npm install -g grunt-cli
fi

# Check if hostnames are reachable or not | https://github.com/beatfreaker/is-reachable-cli
if test ! $(which is-reachable)
then
  npm install -g is-reachable-cli
fi

# Check whether a website is up or down using the isitup.org API | https://github.com/sindresorhus/is-up-cli
if test ! $(which is-up)
then
  npm install -g is-up-cli
fi

# Upload images to imgur | https://github.com/kevva/imgur-uploader-cli
if test ! $(which imgur-uploader)
then
  npm install -g imgur-uploader-cli
fi

# A cli for managing wifi connections on OSX | https://github.com/danyshaanan/osx-wifi-cli
if test ! $(which osx-wifi-cli)
then
  npm install -g osx-wifi-cli
fi

# Get the OS X version of the current system | https://github.com/sindresorhus/osx-version-cli
if test ! $(which osx-version)
then
  npm install -g osx-version-cli
fi

# Simplified and community-driven man pages http://tldr-pages.github.io/ | https://github.com/tldr-pages/tldr-node-client
if test ! $(which tldr)
then
  npm install -g tldr
fi

# Static web publishing for Front-End Developers | https://surge.sh/
if test ! $(which surge)
then
  npm install -g surge
fi

# Test your internet connection speed and ping using speedtest.net from the CLI | https://github.com/sindresorhus/speed-test
if test ! $(which speed-test)
then
  npm install -g speed-test
fi

# Kill all Chrome tabs to improve performance, decrease battery usage, and save memory | https://github.com/sindresorhus/kill-tabs
if test ! $(which kill-tabs)
then
  npm install -g kill-tabs
fi

# Tell Yeoman what to say. Like cowsay, but less cow. | https://github.com/yeoman/yosay
if test ! $(which yosay)
then
  npm install -g yosay
fi

# Get or set the desktop wallpaper | https://github.com/sindresorhus/wallpaper-cli
if test ! $(which wallpaper)
then
  npm install -g wallpaper-cli
fi

# The web's scaffolding tool for modern webapps | http://yeoman.io/
if test ! $(which yo)
then
  npm install -g yo
fi

# Nodejs-based tool for optimizing SVG vector graphics files | https://github.com/svg/svgo
if test ! $(which svgo)
then
  npm install -g svgo
fi

# https://github.com/npm/npm/issues/11385
npm install -g npm@latest
#npm update npm -g
#sudo npm update -g
