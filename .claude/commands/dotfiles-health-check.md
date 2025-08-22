# Dotfiles Health Check

## Usage
```bash
claude dotfiles-health-check
```

## Description
Performs a comprehensive audit of your dotfiles system health, comparing the current system state against the expected dotfiles configuration and identifying any discrepancies, missing configurations, or potential issues.

## Command

Perform a comprehensive audit of my dotfiles system health located at `~/.dotfiles`. Please analyze and report on:

## 1. Symlink Integrity Analysis
- **Core Symlinks**: Check if all `*.symlink` files in git/, ruby/, zsh/ directories are properly linked to home directory with correct targets
- **Application Configs**: Verify symlinks for:
  - `~/.claude/*` → `~/.dotfiles/claude/*` (CLAUDE.md, commands, hooks, settings.json)  
  - `~/.config/ghostty/config` → `~/.dotfiles/ghostty/config`
  - `~/Library/Application Support/Code/User/settings.json` → `~/.dotfiles/vscode/settings.json`
  - `~/Library/Application Support/VSCodium/User/settings.json` → `~/.dotfiles/vscodium/settings.json`
  - `~/Library/Application Support/xbar/plugins` → `~/.dotfiles/xbar/plugins`
  - `~/.config/micro/colorschemes/pcs-tc.micro` → `~/.dotfiles/micro/pcs-tc.micro`
- **Git Hooks**: Verify `~/.dotfiles/.git/hooks/pre-commit` → `~/.dotfiles/keyboard/hooks/pre-commit` and is executable
- **Raycast Integration**: Check `~/.dotfiles/raycast/show-keyboard-shortcuts.sh` → `~/.dotfiles/keyboard/show-keyboard-shortcuts.sh`
- **Broken Links**: Identify any broken symlinks, circular references, or missing target files

## 2. Package Management Verification  
- **Homebrew Packages**: Compare `~/.dotfiles/homebrew/Brewfile` against actually installed packages (`brew list`)
- **Missing Dependencies**: Check which packages in Brewfile aren't installed and which installed packages aren't in Brewfile
- **Install Script Dependencies**: For each install.sh script in (claude, ghostty, micro, vscode, vscodium, xbar, keyboard), verify:
  - Required applications are installed and accessible via PATH
  - Dependency checks would pass (imagemagick, chrome, raycast, cleanshot, etc.)
  - Scripts follow consistent patterns (DOTFILES_ROOT setup, validation, error handling)

## 3. Shell Configuration Health
- **Zsh Loading**: Verify all `*.zsh` files are being loaded correctly from:
  - Tool-specific aliases: docker/aliases.zsh, git/aliases.zsh, ruby/aliases.zsh, etc.
  - Path configurations: go/path.zsh, node/path.zsh, ruby/path.zsh, etc.  
  - Completions: git/completion.zsh, ruby/completion.zsh, zsh/completion.zsh
- **Claude Aliases**: Check if claude/aliases.zsh is loaded and `claude` command works with MCP config
- **Performance**: Analyze zsh startup time and identify any slow-loading configurations
- **Conflicts**: Check for duplicate aliases or PATH entries across different .zsh files

## 4. Installation Script Consistency
- **Missing Scripts**: Identify directories that should have install.sh but don't (check for config files that need symlinking)
- **Script Standards**: Verify each install.sh follows the established pattern:
  - Sets `DOTFILES_ROOT` variable correctly
  - Checks for required dependencies  
  - Uses proper symlink validation
  - Has appropriate error handling and user feedback
- **Executable Permissions**: Check all install.sh and hook scripts are executable

## 5. Git Repository Health
- **Repository Status**: Check for uncommitted changes, untracked files that should be tracked, or tracked files that should be ignored
- **Gitignore Effectiveness**: Verify .gitignore is properly excluding generated files (keyboard.png, etc.) and local configs
- **Hook Functionality**: Test if pre-commit hook runs correctly and generates keyboard.png from keyboard.html
- **Sensitive Data**: Scan for accidentally committed secrets, API keys, or personal information

## 6. macOS-Specific Configuration
- **Application Paths**: Verify expected macOS application paths exist for:
  - Google Chrome (for keyboard screenshot generation)
  - Ghostty, VS Code, VSCodium, Raycast, CleanShot X, xbar
- **Library Directories**: Check proper creation of app support directories
- **Permissions**: Verify file permissions are appropriate for macOS security model

## 7. System Integration Issues
- **PATH Conflicts**: Check for PATH pollution or missing entries
- **Environment Variables**: Verify essential env vars are set (EDITOR, DOTFILES paths, etc.)
- **Service Dependencies**: Check if background services (gitlab-runner, postgresql, etc.) are properly configured
- **File System**: Check for adequate disk space and proper file system permissions

## Output Requirements
For each issue found, provide:
1. **Specific Description**: What exactly is wrong
2. **Impact Assessment**: How this affects functionality  
3. **Fix Command**: Exact command(s) to resolve the issue
4. **Prevention**: How to avoid this issue in the future

Prioritize findings by:
- **Critical**: Breaks core functionality (broken symlinks, missing essential tools)
- **Important**: Reduces functionality (missing packages, slow performance)  
- **Optimization**: Improvements and best practices

End with a summary of overall dotfiles health and next recommended actions.