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

# Configure Claude CLI to skip onboarding and use API key
mkdir -p ~/.claude
cat > ~/.claude.json << EOF
{
  "primaryApiKey": "$ANTHROPIC_API_KEY",
  "hasCompletedOnboarding": true,
  "lastOnboardingVersion": "1.0.0"
}
EOF

# Create permissive settings
cat > ~/.claude/settings.json << EOF
{
  "permissions": {
    "allow": ["*"],
    "deny": []
  }
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
