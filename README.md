# Dotfiles

Personal development environment configuration with modern zsh, enhanced completions, and productivity tools.

## Quick Setup

```sh
script/bootstrap  # Interactive setup with prompts
```

**Setup Types:**
- **Essential**: CLI tools, git, programming languages (servers, remote dev)
- **Workstation**: Essential + GUI apps, browsers, IDEs (local development)

## Daily Use Tips

### Shell & Navigation
- `↑/↓` - Smart history search (searches as you type)
- `Tab` - Enhanced completions with menu navigation
- `..`, `...`, `....` - Navigate up directories quickly
- `mkd dirname` - Create directory and cd into it
- `extract file.zip` - Universal archive extractor

### Git Shortcuts
- `gs` - Git status
- `ga` - Git add all
- `gc` - Git commit
- `gco` - Git checkout
- `gp` - Git push
- `gl` - Pretty git log

### Productivity
- `reload` - Reload shell configuration
- `brewup` - Update Homebrew and packages
- `finder` - Open current directory in Finder
- `timer` - Simple command-line timer

### File Operations
- `ll` - Detailed file listing
- `ff pattern` - Fast file finder (uses fd/find)
- `rg pattern` - Fast grep (ripgrep)
- `bat file` - Syntax-highlighted cat

## Key Features

- **Smart Shell**: Auto-suggestions, syntax highlighting, fast completions
- **Git Integration**: Status in prompt, cached for performance
- **Modern Tools**: fd, rg, bat, exa with smart fallbacks
- **Keyboard Shortcuts**: [Custom layout](https://dimitrieh.gitlab.io/dotfiles) with Hyper key

## How It Works

**File Conventions:**
- `*.symlink` → Linked to home directory (e.g., `git/gitconfig.symlink` → `~/.gitconfig`)
- `install.sh` → App-specific setup scripts
- `*.zsh` → Shell configs (aliases, paths, completions)

**Adding Apps:**
1. Create app directory
2. Add config files (`.symlink` or `install.sh`)
3. Run `script/install`

## Maintenance

```sh
# Health check
dot health

# Update packages
brewup

# Reload configuration
reload
```

## Thanks

Forked from [Zach Holman](https://github.com/holman/dotfiles) → [Ryan Bates](https://github.com/ryanb/dotfiles)