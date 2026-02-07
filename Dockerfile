# syntax=docker/dockerfile:1

# ------------------------------------------------------------------------------
# Base stage - common setup
# ------------------------------------------------------------------------------
FROM node:22-alpine AS base

# Install system dependencies and sudo
RUN apk add --no-cache \
    bash \
    sudo \
    git \
    curl \
    # pyenv build dependencies
    build-base \
    libffi-dev \
    openssl-dev \
    bzip2-dev \
    zlib-dev \
    xz-dev \
    readline-dev \
    sqlite-dev \
    tk-dev \
    linux-headers \
    && echo "ralph ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ralph \
    && chmod 0440 /etc/sudoers.d/ralph

# Install pyenv, Python 3.13, and pipenv globally
ENV PYENV_ROOT=/usr/local/pyenv
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
RUN curl https://pyenv.run | bash \
    && pyenv install 3.13 \
    && pyenv global 3.13 \
    && pip install --upgrade pip \
    && pip install pipenv

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user with sudo access (delete existing node user first)
RUN deluser --remove-home node 2>/dev/null || true \
    && adduser -D -u 1000 ralph \
    && addgroup ralph wheel

# Copy entrypoint script (as root, before switching user)
# Convert CRLF to LF (Windows line endings break shebang)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Create workspace and .claude directories
RUN mkdir -p /workspace /home/ralph/.claude \
    && chown -R ralph:ralph /workspace /home/ralph/.claude

# Copy agent definitions
COPY .claude/agents/ /home/ralph/.claude/agents/
RUN chown -R ralph:ralph /home/ralph/.claude/agents/

# Copy container-specific hooks for auto-exit behavior
# Convert CRLF to LF (Windows line endings break shebang)
COPY --chown=ralph:ralph container-claude/hooks /home/ralph/.claude/hooks
RUN sed -i 's/\r$//' /home/ralph/.claude/hooks/*.sh \
    && chmod +x /home/ralph/.claude/hooks/*.sh

# ------------------------------------------------------------------------------
# Test stage
# ------------------------------------------------------------------------------
FROM base AS test

COPY test_ralph.sh /workspace/test_ralph.sh
RUN sed -i 's/\r$//' /workspace/test_ralph.sh \
    && chmod +x /workspace/test_ralph.sh \
    && chown ralph:ralph /workspace/test_ralph.sh

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
