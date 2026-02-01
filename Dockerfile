# syntax=docker/dockerfile:1

# ------------------------------------------------------------------------------
# Base stage - common setup
# ------------------------------------------------------------------------------
FROM node:22-alpine AS base

# Install sudo and configure passwordless access
RUN apk add --no-cache \
    bash \
    sudo \
    git \
    curl \
    python3 \
    py3-pip \
    && echo "ralph ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ralph \
    && chmod 0440 /etc/sudoers.d/ralph

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user with sudo access (delete existing node user first)
RUN deluser --remove-home node 2>/dev/null || true \
    && adduser -D -u 1000 ralph \
    && addgroup ralph wheel

# Copy entrypoint script (as root, before switching user)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create workspace and .claude directories
RUN mkdir -p /workspace /home/ralph/.claude \
    && chown -R ralph:ralph /workspace /home/ralph/.claude

# ------------------------------------------------------------------------------
# Test stage
# ------------------------------------------------------------------------------
FROM base AS test

COPY test_ralph.sh /workspace/test_ralph.sh
RUN chmod +x /workspace/test_ralph.sh && chown ralph:ralph /workspace/test_ralph.sh

USER ralph
WORKDIR /workspace

CMD ["/workspace/test_ralph.sh"]

# ------------------------------------------------------------------------------
# Runtime stage (default)
# ------------------------------------------------------------------------------
FROM base AS runtime

USER ralph
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
