---
description: Create a new script in the bin directory with proper error handling and dotfiles integration
allowed-tools: Write, Read, Bash, Grep
argument-hint: <script-name> <script-type> "<description of what it should do>"
---

# Create Bin Script

Create a new executable script in the `/Users/dimitrie/.dotfiles/bin/` directory with proper error handling, validation, and integration with the dotfiles system.

## Arguments
- **Script Name**: $ARGUMENTS (first argument) - Name of the script (without extension)
- **Script Type**: $ARGUMENTS (second argument) - Type: bash, shell, python3, node
- **Description**: $ARGUMENTS (remaining arguments) - What the script should do

## Requirements

### Script Standards
- Add proper shebang based on script type
- Include descriptive header comment
- Implement comprehensive error handling with exit codes
- Add input validation and usage instructions
- Use proper variable quoting and trap cleanup
- Follow dotfiles conventions (use `$DOTFILES` variables where applicable)

### Error Handling Pattern
```bash
#!/bin/bash
set -euo pipefail

show_usage() {
  echo "Usage: $0 <args>"
  echo "Description: [what it does]"
}

cleanup() {
  # Clean up temp files/resources
}
trap cleanup EXIT INT TERM
```

### Python Scripts
- Use `#!/usr/bin/env python3` shebang
- Follow the Python usage rule from CLAUDE.md
- Add proper argument parsing and error handling

### Integration Points
- Scripts are automatically available via PATH (`system/path.zsh` adds `$ZSH/bin`)
- Can use smart aliases (cat → bat fallback from `zsh/aliases.zsh`)
- Consider dotfiles environment variables (`$DOTFILES`, `$ZSH`, etc.)

### Quality Checklist
- [ ] Executable permissions set (`chmod +x`)
- [ ] Proper shebang for script type
- [ ] Input validation with helpful usage message
- [ ] Error handling with appropriate exit codes
- [ ] Resource cleanup (temp files, etc.)
- [ ] Progress feedback for long operations
- [ ] Consistent output formatting

## Implementation Steps

1. **Validate Arguments**: Ensure all required arguments provided
2. **Choose Template**: Select appropriate template based on script type
3. **Generate Script**: Create script with proper structure and error handling
4. **Set Permissions**: Make executable (`chmod +x`)
5. **Test**: Verify script works and handles edge cases
6. **Document**: Show usage and integration information

## Examples

**Bash utility:**
```
/create-bin-script backup-project bash "Create timestamped backup of current directory"
```

**Python tool:**
```
/create-bin-script json-format python3 "Format and validate JSON from stdin or file"
```

**System integration:**
```
/create-bin-script git-cleanup bash "Clean up merged branches and optimize repository"
```

Generate robust, well-structured scripts that follow the quality standards established in the existing bin directory tools.