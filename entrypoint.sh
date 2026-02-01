#!/bin/bash
set -e

# Ralph entrypoint - runs Claude in a loop with dangerously-skip-permissions
#
# Environment variables:
#   ANTHROPIC_API_KEY    - Required API key
#   RALPH_MAX_ITERATIONS - Maximum number of loop iterations (0 = unlimited)

MAX_ITERATIONS="${RALPH_MAX_ITERATIONS:-0}"
PROMPT_FILE="/workspace/prompt.md"

# Check for API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "Error: ANTHROPIC_API_KEY is not set"
    exit 1
fi

# Configure Claude CLI to skip onboarding and use API key directly
mkdir -p ~/.claude

# Extract key parts for approval list (first 21 chars and last 20 chars)
API_KEY_START="${ANTHROPIC_API_KEY:0:21}"
API_KEY_END="${ANTHROPIC_API_KEY: -20}"

cat > ~/.claude.json << EOF
{
  "primaryApiKey": "$ANTHROPIC_API_KEY",
  "hasCompletedOnboarding": true,
  "lastOnboardingVersion": "99.0.0",
  "customApiKeyResponses": {
    "approved": ["$API_KEY_START", "$API_KEY_END"],
    "rejected": []
  },
  "hasDismissedApiKeyBanner": true,
  "hasAcknowledgedCostThreshold": true,
  "bypassPermissionsModeAccepted": true
}
EOF

# Create permissive settings with bypass mode
cat > ~/.claude/settings.json << EOF
{
  "permissions": {
    "allow": ["*"],
    "deny": [],
    "defaultMode": "bypassPermissions"
  },
  "bypassPermissions": true
}
EOF

if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: prompt.md not found in /workspace"
    echo "Your mounted directory must contain a prompt.md file"
    exit 1
fi

echo "=== Ralph Mode ==="
echo "Prompt file: $PROMPT_FILE"
echo "Max iterations: ${MAX_ITERATIONS:-unlimited}"
echo "Working directory: $(pwd)"
echo "=================="

iteration=0

while :; do
    iteration=$((iteration + 1))

    echo ""
    echo ">>> Iteration $iteration"
    echo ""

    cat "$PROMPT_FILE" | claude --dangerously-skip-permissions

    # Check iteration limit
    if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$iteration" -ge "$MAX_ITERATIONS" ]; then
        echo ""
        echo "=== Reached max iterations ($MAX_ITERATIONS) ==="
        break
    fi
done
