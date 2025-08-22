# Zsh Configuration

Modern zsh setup with enhanced completions, async prompt, and plugin management.

## Features

- **Enhanced Completions**: Menu selection, fuzzy matching, colored output
- **Performance Optimized Prompt**: Cached git status for faster directory changes
- **Modern Plugin Management**: Zinit for fast plugin loading
- **Smart Aliases**: Conditional fallbacks for better portability

## Setup for New Machine

1. **Install dependencies:**
   ```bash
   brew bundle --file=~/.dotfiles/Brewfile
   ```

2. **Reload shell:**
   ```bash
   source ~/.zshrc
   ```

## New Plugins Added

- **zsh-syntax-highlighting**: Real-time command syntax highlighting
- **zsh-history-substring-search**: Better up/down arrow history navigation
- **zsh-completions**: Extended completions for hundreds of commands
- **zsh-autosuggestions**: Intelligent command suggestions

## Performance Improvements

- Git status cached for 5 seconds
- Unpushed commits cached for 10 seconds
- Completion results cached
- Faster git status checks using porcelain format

## Key Bindings

- `↑/↓`: History substring search
- `Tab`: Enhanced completion with menu selection
- `Ctrl+P/N`: Alternative history substring search