---
description: Comprehensive audit of dotfiles system health and configuration
allowed-tools: Bash, Read, LS, Grep, Glob
argument-hint: <optional: specific area to focus on (symlinks, packages, shell, etc.)>
---

# Dotfiles Health Check

Perform a comprehensive audit of my dotfiles system health located at `~/.dotfiles`. 

Focus areas: $ARGUMENTS (if not specified, analyze all areas)

Analyze and report on:

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
- **Homebrew Packages**: Compare `~/.dotfiles/homebrew/Brewfile` against installed packages (`brew list`)
- **Missing Dependencies**: Check packages in Brewfile vs installed packages
- **Install Script Dependencies**: For each install.sh script, verify required applications are installed and accessible

## 3. Shell Configuration Health
- **Zsh Loading**: Verify all `*.zsh` files are loaded (aliases, paths, completions)
- **Claude Aliases**: Check if claude/aliases.zsh is loaded and `claude` command works
- **Alias Safety**: Verify aliases don't override critical system commands (ls, cd, rm, cp, mv, etc.)
- **Tool Conflicts**: Check aliases don't interfere with common CLI tools (git, docker, npm, etc.)
- **Command Validity**: Test that aliases point to existing commands and valid paths
- **Version Conflicts**: Identify aliases that might cause issues with old/new tool versions
- **Performance**: Analyze zsh startup time and identify slow configurations
- **Duplicate Detection**: Check for duplicate aliases or conflicting PATH entries

## 4. Installation Script Consistency
- **Missing Scripts**: Identify directories missing install.sh scripts
- **Script Standards**: Verify install.sh scripts follow patterns (DOTFILES_ROOT, dependencies, error handling)
- **Executable Permissions**: Check install.sh and hook scripts are executable

## 5. Git Repository Health
- **Repository Status**: Check for uncommitted changes and proper .gitignore usage
- **Hook Functionality**: Test pre-commit hook runs and generates keyboard.png
- **Sensitive Data**: Scan for accidentally committed secrets or personal information

## 6. macOS-Specific Configuration
- **Application Paths**: Verify expected macOS application paths exist (Chrome, Ghostty, VS Code, etc.)
- **Library Directories**: Check proper creation of app support directories
- **Permissions**: Verify appropriate file permissions for macOS security

## 7. System Integration
- **PATH**: Check for PATH conflicts or missing entries
- **Environment Variables**: Verify essential env vars are set (EDITOR, DOTFILES paths)
- **Services**: Check background services are properly configured
- **File System**: Check disk space and file system permissions

## Output Format
For each issue found, provide:
1. **Issue**: What exactly is wrong
2. **Impact**: How this affects functionality  
3. **Fix**: Exact command(s) to resolve the issue

Prioritize findings by severity: **Critical** → **Important** → **Optimization**

End with a summary of overall dotfiles health and recommended actions.