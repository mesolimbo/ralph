#!/bin/bash
set -e

# Ralph entrypoint - runs Claude in a loop with dangerously-skip-permissions
#
# Environment variables:
#   CLAUDE_CODE_OAUTH_TOKEN - Required OAuth token
#   RALPH_MAX_ITERATIONS    - Maximum number of loop iterations (0 = unlimited)

MAX_ITERATIONS="${RALPH_MAX_ITERATIONS:-0}"
PROMPT_FILE="/workspace/prompt.md"

# Check for OAuth token
if [ -z "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
    echo "Error: CLAUDE_CODE_OAUTH_TOKEN is not set"
    exit 1
fi

# Configure Claude CLI to skip onboarding and use OAuth token
mkdir -p ~/.claude

cat > ~/.claude.json << EOF
{
  "oauthToken": "$CLAUDE_CODE_OAUTH_TOKEN",
  "hasCompletedOnboarding": true,
  "lastOnboardingVersion": "99.0.0",
  "hasDismissedApiKeyBanner": true,
  "hasAcknowledgedCostThreshold": true,
  "bypassPermissionsModeAccepted": true
}
EOF

# Create permissive settings with bypass mode and auto-exit hook
cat > ~/.claude/settings.json << EOF
{
  "permissions": {
    "allow": ["*"],
    "deny": [],
    "defaultMode": "bypassPermissions"
  },
  "bypassPermissions": true,
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/home/ralph/.claude/hooks/stop-and-exit.sh"
          }
        ]
      }
    ]
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

    # Run Claude - the Stop hook will terminate it after completion
    # We use || true to continue the loop even if Claude exits non-zero
    cat "$PROMPT_FILE" | claude --dangerously-skip-permissions || true

    # Check iteration limit
    if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$iteration" -ge "$MAX_ITERATIONS" ]; then
        echo ""
        echo "=== Reached max iterations ($MAX_ITERATIONS) ==="
        break
    fi
done
