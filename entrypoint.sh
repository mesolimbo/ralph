#!/bin/bash
set -e

# Ralph entrypoint - runs Claude in a loop with dangerously-skip-permissions
#
# Environment variables:
#   CLAUDE_CODE_OAUTH_TOKEN - OAuth token (preferred if both are set)
#   ANTHROPIC_API_KEY       - API key (used if OAuth token is not set)
#   RALPH_MAX_ITERATIONS    - Maximum number of loop iterations (0 = unlimited)

MAX_ITERATIONS="${RALPH_MAX_ITERATIONS:-0}"
PROMPT_FILE="/workspace/.ralph/prompt.md"

# Check for authentication - prefer OAuth token over API key
if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
    AUTH_TYPE="oauth"
    echo "Using OAuth token for authentication"
elif [ -n "$ANTHROPIC_API_KEY" ]; then
    AUTH_TYPE="apikey"
    echo "Using API key for authentication"
else
    echo "Error: Neither CLAUDE_CODE_OAUTH_TOKEN nor ANTHROPIC_API_KEY is set"
    echo "Please set one of these environment variables"
    exit 1
fi

# Configure Claude CLI to skip onboarding
mkdir -p ~/.claude

if [ "$AUTH_TYPE" = "oauth" ]; then
    cat > ~/.claude.json << EOF
{
  "oauthToken": "$CLAUDE_CODE_OAUTH_TOKEN",
  "hasCompletedOnboarding": true,
  "lastOnboardingVersion": "99.0.0",
  "hasDismissedApiKeyBanner": true,
  "hasAcknowledgedCostThreshold": true,
  "bypassPermissionsModeAccepted": true,
  "projects": {
    "/workspace": {
      "hasTrustDialogAccepted": true,
      "hasTrustDialogHooksAccepted": true
    }
  },
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@0.0.64",
        "--headless",
        "--browser", "chromium",
        "--caps", "core,testing",
        "--isolated",
        "--no-sandbox"
      ],
      "env": {
        "PLAYWRIGHT_BROWSERS_PATH": "/opt/playwright-browsers"
      }
    }
  }
}
EOF
else
    cat > ~/.claude.json << EOF
{
  "apiKey": "$ANTHROPIC_API_KEY",
  "hasCompletedOnboarding": true,
  "lastOnboardingVersion": "99.0.0",
  "hasDismissedApiKeyBanner": true,
  "hasAcknowledgedCostThreshold": true,
  "bypassPermissionsModeAccepted": true,
  "projects": {
    "/workspace": {
      "hasTrustDialogAccepted": true,
      "hasTrustDialogHooksAccepted": true
    }
  },
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@0.0.64",
        "--headless",
        "--browser", "chromium",
        "--caps", "core,testing",
        "--isolated",
        "--no-sandbox"
      ],
      "env": {
        "PLAYWRIGHT_BROWSERS_PATH": "/opt/playwright-browsers"
      }
    }
  }
}
EOF
fi

# Create permissive settings with bypass mode and auto-exit hook.
# The Stop hook is required because we run claude in interactive mode (so the
# user can see the agent work). Interactive claude does not exit on its own at
# end of turn — the hook signals the entrypoint to kill it and restart the loop.
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
    echo "Error: prompt.md not found in /workspace/.ralph/"
    echo "Your mounted directory must contain a .ralph/prompt.md file"
    exit 1
fi

if [ ! -s "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE exists but is empty."
    echo "Put your goal/instructions in it (see .ralph/prompt.md.template for the recommended scaffold)."
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

    # Clear any stale stop signal from the previous iteration.
    rm -f /tmp/ralph-stop

    # Run claude in INTERACTIVE mode with the prompt passed as a positional arg.
    # Passing as an arg (rather than piping to stdin) leaves stdin attached to
    # the docker -it TTY, which claude's UI needs for raw-mode rendering.
    # Backgrounded so we can poll for the Stop-hook signal.
    claude --dangerously-skip-permissions "$(cat "$PROMPT_FILE")" &
    CLAUDE_PID=$!

    # Wait for claude to exit on its own OR for the Stop hook to signal end-of-turn.
    while kill -0 "$CLAUDE_PID" 2>/dev/null; do
        if [ -f /tmp/ralph-stop ]; then
            echo ""
            echo ">>> Stop hook fired, terminating claude"
            kill -TERM "$CLAUDE_PID" 2>/dev/null
            sleep 2
            kill -KILL "$CLAUDE_PID" 2>/dev/null || true
            break
        fi
        sleep 1
    done
    wait "$CLAUDE_PID" 2>/dev/null || true

    # Check iteration limit
    if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$iteration" -ge "$MAX_ITERATIONS" ]; then
        echo ""
        echo "=== Reached max iterations ($MAX_ITERATIONS) ==="
        break
    fi
done
