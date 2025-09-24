#!/bin/sh
#
# Install Claude Code configuration
#

# Get dotfiles root directory
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# Check for Claude Code CLI
if test ! $(which claude)
then
  echo "  x Claude Code CLI not found. Install it first:"
  echo "    Visit https://claude.ai/code for installation instructions"
  exit 1
fi

# Create ~/.claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

# Create symlinks for dotfiles-managed claude configuration
ln -sf "$DOTFILES_ROOT/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$DOTFILES_ROOT/claude/commands" "$HOME/.claude/commands"
ln -sf "$DOTFILES_ROOT/claude/hooks" "$HOME/.claude/hooks"
ln -sf "$DOTFILES_ROOT/claude/settings.json" "$HOME/.claude/settings.json"
ln -sf "$DOTFILES_ROOT/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
ln -sf "$DOTFILES_ROOT/claude/mcp-configs" "$HOME/.claude/mcp-configs"

# Validate the symlinks were created correctly
validation_failed=false
for file in CLAUDE.md commands hooks settings.json statusline-command.sh mcp-configs; do
  if [ "$(readlink "$HOME/.claude/$file")" != "$DOTFILES_ROOT/claude/$file" ]; then
    echo "  ✗ Claude Code $file link failed"
    validation_failed=true
  fi
done

if [ "$validation_failed" = "false" ]; then
  echo "  ✓ Claude Code configuration linked and verified"
else
  exit 1
fi