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

### Project Management
- `pj project-name` - Jump to project in ~/Projects
- `pj open project-name` - Open project in editor
- `shd project-name` - Jump to self-hosted project in ~/self-hosted
- `shd open project-name` - Open self-hosted project in editor

### Advanced Git Tools (bin/)
- `git-all` - Stage all unstaged files
- `git-amend` - Amend last commit with current changes
- `git-copy-branch-name` - Copy current branch name to clipboard
- `git-delete-local-merged` - Delete local branches that are merged
- `git-nuke` - Hard reset and clean repository
- `git-unpushed` - Show unpushed commits
- `git-up` - Smart pull with rebase
- `git-wtf` - Show repository status summary

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
- `bin/` → Personal command toolkit (28 executable scripts added to PATH)

**The `bin/` Directory:**
Contains 28 executable tools automatically available system-wide:
- **Git Workflow**: 16 git-* scripts for advanced git operations
- **Development**: Multi-repo management, safety checks, utilities
- **Productivity**: File transfer, image resizing, text generation

All scripts are integrated via PATH and support tab completion for discovery.

**Adding Apps:**
1. Create app directory
2. Add config files (`.symlink` or `install.sh`)
3. Run `script/install`

## Maintenance

```sh
# Update packages
brewup

# Reload configuration
reload
```

## Thanks

Forked from [Zach Holman](https://github.com/holman/dotfiles) → [Ryan Bates](https://github.com/ryanb/dotfiles)