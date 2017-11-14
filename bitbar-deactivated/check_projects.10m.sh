#!/bin/bash
number=$(~/.dotfiles/bin/clustergit -q -C --warn-unversioned -d ~/projects;);
echo "${number} ✾";
echo "---";
~/.dotfiles/bin/clustergit -q -H -R --warn-unversioned -d ~/projects -a 80;
