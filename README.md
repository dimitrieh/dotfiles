# Dotfiles

## Install

### Quick Setup (Recommended)

Run this for interactive setup:

```sh
script/bootstrap  # Interactive setup - prompts for installation type and creates symlinks
```

The bootstrap script will:
1. Set up git configuration (if needed)
2. Ask whether you want essential or workstation setup
3. Create symlinks for dotfiles
4. Install packages based on your choice

### Manual Installation Options

If you prefer to choose manually:

```sh
# Essential setup (CLI tools only) - for servers, remote machines
script/install

# Workstation setup (essentials + GUI apps) - for local development
script/install --workstation
```

## Installation Types

**Essential Setup:**
- CLI development tools, version control, programming languages
- Text processing, terminal utilities, build tools
- Perfect for servers, remote development, or minimal setups
- Focused on command-line productivity

**Workstation Setup:**
- Everything from Essential setup PLUS
- GUI applications: browsers, IDEs, communication apps
- Desktop productivity tools, media applications
- Perfect for local development machines with displays

## How it works

### Installation Process

1. **Bootstrap** (`script/bootstrap`)
   - Prompts for git author name/email if not configured
   - Creates symlinks for all `*.symlink` files to your home directory
   - Installs homebrew dependencies on macOS

2. **Install Scripts** (`script/install`)
   - Automatically finds and runs all `install.sh` scripts in any subdirectory
   - Each application's `install.sh` handles its specific setup (creating directories, symlinks, etc.)

### Conventions

- **`*.symlink`** - Any file ending in `.symlink` gets automatically symlinked to `~` during bootstrap
  - Example: `git/gitconfig.symlink` → `~/.gitconfig`

- **`install.sh`** - Scripts that handle application-specific setup
  - Automatically discovered and executed by `script/install`
  - Should check for dependencies, create necessary symlinks, and validate setup

- **`*.zsh`** - Shell configuration files that get automatically sourced by zsh
  - `aliases.zsh` - Command aliases specific to that tool (e.g., docker aliases, git shortcuts)
  - `path.zsh` - PATH modifications for that tool
  - `completion.zsh` - Shell completions
  - All `.zsh` files are loaded automatically by the zsh configuration

### Adding New Applications

To add configuration for a new application:

1. Create a directory with the application name
2. Add your configuration files
3. Either:
   - Name files with `.symlink` suffix for automatic linking to home directory
   - Create an `install.sh` script for custom setup logic
4. Run `script/install` to execute your new install script

## Zsh Configuration

Modern zsh setup with enhanced completions, async prompt, and plugin management.

### Features

- **Enhanced Completions**: Menu selection, fuzzy matching, colored output
- **Performance Optimized Prompt**: Cached git status for faster directory changes
- **Modern Plugin Management**: Zinit for fast plugin loading
- **Smart Aliases**: Conditional fallbacks for better portability

### Setup for New Machine

1. **Install dependencies:**
   ```bash
   brew bundle --file=~/.dotfiles/Brewfile
   ```

2. **Reload shell:**
   ```bash
   source ~/.zshrc
   ```

### New Plugins Added

- **zsh-syntax-highlighting**: Real-time command syntax highlighting
- **zsh-history-substring-search**: Better up/down arrow history navigation
- **zsh-completions**: Extended completions for hundreds of commands
- **zsh-autosuggestions**: Intelligent command suggestions

### Performance Improvements

- Git status cached for 5 seconds
- Unpushed commits cached for 10 seconds
- Completion results cached
- Faster git status checks using porcelain format

### Key Bindings

- `↑/↓`: History substring search
- `Tab`: Enhanced completion with menu selection
- `Ctrl+P/N`: Alternative history substring search

## Keyboard shortcuts

Keyboard shortcuts are configured with a Hyper key. The layout can be found [here](https://dimitrieh.gitlab.io/dotfiles)

## Thanks

I forked from [Zach Holman](https://github.com/holman/dotfiles), which again forked from [Ryan Bates](http://github.com/ryanb)' excellent
[dotfiles](https://github.com/ryanb/dotfiles)
