#!/bin/bash

# Read JSON input from stdin
INPUT=$(cat)

# Extract the command from the JSON input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Check if this is a git commit command
if [[ "$COMMAND" == *"git commit"* ]]; then
    # Check for Claude references in the command
    if echo "$COMMAND" | grep -iqE "(generated with claude|co-authored-by: claude|claude code|🤖 generated)"; then
        echo "❌ ERROR: Commit message contains Claude references. Please remove them and commit again." >&2
        echo "Blocked command: $COMMAND" >&2
        exit 2
    fi
fi

# Allow the command to proceed
exit 0