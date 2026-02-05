![Ralph](ralph.png)

# Ralph - Dockerized Claude in Unrestricted Mode

Ralph runs Claude CLI in a Docker container with:
- Full sudo access (no password)
- `--dangerously-skip-permissions` flag enabled
- Configurable iteration loop
- Mounted workspace directory

## Quick Start

```bash
# Copy .env.template to .env
cp .env.template .env

# Set ONE of these authentication methods in .env:
# Option 1: OAuth token (recommended for long-lived sessions)
#   Generate with: claude setup-token
#   Set: CLAUDE_CODE_OAUTH_TOKEN=your-token-here
#
# Option 2: API key
#   Set: ANTHROPIC_API_KEY=your-api-key-here

# Build and run with a workspace directory
make ralph WORKSPACE=/path/to/your/project
```

## Usage

### Build

```bash
make build      # Build runtime image
make build-test # Build test image
```

### Test

```bash
make test       # Run tests in Docker
```

### Run

```bash
# Basic usage - runs indefinitely until manually stopped
make ralph WORKSPACE=/path/to/workspace

# With iteration limit
make ralph WORKSPACE=/path/to/workspace MAX_ITERATIONS=5
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `WORKSPACE` | Directory to mount as `/workspace` (must contain `.ralph/prompt.md`) | Required |
| `MAX_ITERATIONS` | Maximum loop iterations (0 = unlimited) | 0 |

## How It Works

1. The container mounts your workspace directory to `/workspace`
2. On each iteration, it reads `.ralph/prompt.md` and pipes it to Claude
3. Claude runs with `--dangerously-skip-permissions` (no tool restrictions)
4. The loop continues until `MAX_ITERATIONS` is reached (or forever if 0)

## Prompt File

Create a `.ralph/prompt.md` file in your workspace directory with instructions for Claude:

```bash
mkdir -p /path/to/your/project/.ralph
cp prompt.md.template /path/to/your/project/.ralph/prompt.md
# Edit the file with your instructions
```

See `prompt.md.template` for an example.

## Security Warning

This container runs Claude with **no permission restrictions** and **full sudo access**. Only use it:
- In isolated environments
- With trusted prompt files
- On non-sensitive codebases

## Requirements

- Docker
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Authentication via one of:
  - OAuth token (generate with `claude setup-token`) - set `CLAUDE_CODE_OAUTH_TOKEN` in `.env`
  - API key - set `ANTHROPIC_API_KEY` in `.env`
- Note: If both are set, OAuth token takes priority
