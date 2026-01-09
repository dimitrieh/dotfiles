#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Skip if command runs inside container (podman/docker)
if [[ "$COMMAND" =~ ^(podman|docker)[[:space:]] ]]; then
    exit 0
fi

# Block bare npm/npx commands
if [[ "$COMMAND" =~ ^(npm|npx)[[:space:]] ]]; then
    echo "npm/npx commands on host are not allowed." >&2
    echo "Use: podman compose run --rm dev npm <command>" >&2
    echo "Or: podman compose run --rm dev npx <command>" >&2
    exit 2
fi

exit 0
