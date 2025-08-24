---
description: Comprehensive audit of dotfiles system health and configuration
allowed-tools: Bash, Read, LS, Grep, Glob
argument-hint: <optional: specific area to focus on (symlinks, packages, shell, etc.)>
---

# Dotfiles Health Check

Perform a comprehensive audit of my dotfiles system health located at `~/.dotfiles`. 

Focus areas: $ARGUMENTS (if not specified, analyze all areas)

**IMPORTANT**: Verify all assumptions before reporting issues:
- Check paths exist before assuming they should be linked
- Confirm applications are installed before checking configs
- Test commands exist before validating aliases

Analyze and report on:

## 1. Symlink Integrity Analysis
- **Core Symlinks**: Check all `*.symlink` files are properly linked to home directory
- **Application Configs**: Verify expected symlinks exist and point to correct targets
- **Git Hooks**: Check hooks are properly linked and executable
- **Broken Links**: Identify any broken symlinks, circular references, or missing targets

## 2. Package Management Verification  
- **Homebrew Packages**: Compare Brewfiles against installed packages
- **Missing Dependencies**: Identify uninstalled packages from Brewfiles
- **Install Scripts**: Verify dependencies for install.sh scripts

## 3. Shell Configuration Health
- **Zsh Loading**: Verify all `*.zsh` files are loaded properly
- **Alias Safety**: Check aliases don't override critical system commands
- **Command Validity**: Test aliases point to existing commands
- **Performance**: Analyze zsh startup time and identify bottlenecks
- **Duplicate Detection**: Check for duplicate aliases or PATH entries

## 4. Installation Script Consistency
- **Missing Scripts**: Identify directories missing install.sh scripts
- **Script Standards**: Verify install.sh scripts follow patterns (DOTFILES_ROOT, dependencies, error handling)
- **Executable Permissions**: Check install.sh and hook scripts are executable

## 5. Git Repository Health
- **Repository Status**: Check for uncommitted changes and proper .gitignore usage
- **Hook Functionality**: Test pre-commit hook runs and generates keyboard.png
- **Sensitive Data**: Scan for accidentally committed secrets or personal information

## 6. OS-Specific Configuration
- **Application Paths**: Verify expected application paths exist
- **Library Directories**: Check proper directory structure
- **Permissions**: Verify appropriate file permissions

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