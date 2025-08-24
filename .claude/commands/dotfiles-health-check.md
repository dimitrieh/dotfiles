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

## 3.5. Alias and Function Conflict Analysis
- **Extract All Aliases**: Find all `alias` definitions in dotfiles
- **Extract All Functions**: Find all custom functions (pj, shd, etc.)
- **System Command Conflicts**: Check against common system commands (sh, ls, cd, cp, mv, rm, cat, vi, etc.)
- **Single Letter Conflicts**: Verify no dangerous single-letter overrides (especially w, which exists in system)
- **Short Name Analysis**: Review 1-3 character aliases for potential conflicts
- **Best Practice Validation**: Ensure git aliases use `g*` pattern and follow safe conventions

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

## Implementation Commands for Conflict Analysis

### Extract All Aliases
```bash
grep -h "^alias " ~/.dotfiles/**/*.zsh 2>/dev/null | sort | uniq
```

### Extract All Functions  
```bash
# Functions with () syntax
grep -h "^[a-zA-Z][a-zA-Z0-9_]* ()" ~/.dotfiles/**/*.zsh ~/.dotfiles/**/*.sh 2>/dev/null | sort | uniq

# Functions with 'function' keyword
grep -h "^function " ~/.dotfiles/**/*.zsh ~/.dotfiles/**/*.sh 2>/dev/null | sort | uniq
```

### Check Short Aliases (1-3 characters)
```bash
short_aliases=$(grep "^alias " ~/.dotfiles/**/*.zsh 2>/dev/null | grep -E "alias [a-z]{1,3}=" | cut -d'=' -f1 | cut -d' ' -f2)
echo "$short_aliases" | sort
```

### Check System Command Conflicts
```bash
# Check against critical system commands
critical_cmds="sh bash zsh ls cd cp mv rm cat less more grep find sort cut awk sed vi vim git ssh scp man ps top du df tar zip who id su go run cc gcc pip npm gem"

# Check single letter system commands
for letter in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
    sys_cmd=$(command -v $letter 2>/dev/null | grep -E "^(/bin/|/usr/bin/|/usr/sbin/|/sbin/)")
    if [ -n "$sys_cmd" ]; then
        echo "$letter: $sys_cmd"
        # Check if we override it
        our_alias=$(alias $letter 2>/dev/null || echo "")
        if [ -n "$our_alias" ]; then
            echo "  ⚠️  WE OVERRIDE: $our_alias"
        fi
    fi
done
```

### Validate Function Safety
```bash
# Check if functions conflict with system commands
funcs="pj shd o title"  # Update this list as functions are added
echo "$funcs" | tr ' ' '\n' | while read func; do
    echo -n "$func: "
    system_path=$(PATH="/usr/bin:/bin:/usr/sbin:/sbin" command -v $func 2>/dev/null)
    if [ -n "$system_path" ]; then
        echo "⚠️  conflicts with system command at $system_path"
    else
        echo "✅ no conflict"
    fi
done
```

### Safe Naming Guidelines
When adding new aliases/functions, avoid:
- **Single letters**: Especially `w` (system command), `c`, `d`, `f`, `h`, `i`, `j`, `k`, `l`, `m`, `n`, `p`, `r`, `s`, `t`, `x`  
- **Core commands**: `sh`, `ls`, `cd`, `cp`, `mv`, `rm`, `cat`, `grep`, `find`, `sort`, `cut`
- **Development tools**: `go`, `cc`, `gcc`, `npm`, `pip`, `gem`
- **Follow patterns**: Git aliases should use `g*` prefix, use descriptive short names like `dl`, `dt`