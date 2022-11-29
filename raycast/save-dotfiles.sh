#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Save dotfiles
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }
# @raycast.needsConfirmation true

# Documentation:
# @raycast.description Commit and Push your dotfiles directly to your remote
# @raycast.author Dimitrie Hoekstra
# @raycast.authorURL dimitr.ie

cd ~/.dotfiles && git add . && git commit -m "$1" && git push origin HEAD && echo "Changes to dotfiles add, committed, and pushed."
