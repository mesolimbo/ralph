# syntax=docker/dockerfile:1

# ------------------------------------------------------------------------------
# Base stage - common setup
# ------------------------------------------------------------------------------
FROM node:22-slim AS base

# Install system dependencies and sudo
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    sudo \
    git \
    curl \
    ca-certificates \
    # pyenv build dependencies
    build-essential \
    libffi-dev \
    libssl-dev \
    libbz2-dev \
    zlib1g-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    tk-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv, Python 3.13, and pipenv globally
ENV PYENV_ROOT=/usr/local/pyenv
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
RUN curl https://pyenv.run | bash \
    && pyenv install 3.13 \
    && pyenv global 3.13 \
    && pip install --upgrade pip \
    && pip install pipenv

# Install Claude CLI and Playwright MCP server globally
# Install Chromium using the MCP server's bundled Playwright (not the global one)
# so the browser revision matches what the MCP server expects
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright-browsers
RUN npm install -g @anthropic-ai/claude-code @playwright/mcp@0.0.64 \
    && cd /usr/local/lib/node_modules/@playwright/mcp \
    && npx playwright install --with-deps chromium \
    && chmod -R o+rx /opt/playwright-browsers

# Install Docker CLI (Docker-out-of-Docker). The daemon is the host's, reached
# via /var/run/docker.sock mounted at runtime. We ship just the static client
# binary plus the compose plugin — no daemon, no containerd, no --privileged.
ARG DOCKER_VERSION=27.3.1
ARG DOCKER_COMPOSE_VERSION=2.29.7
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
        x86_64)  docker_arch=x86_64;  compose_arch=x86_64  ;; \
        aarch64) docker_arch=aarch64; compose_arch=aarch64 ;; \
        *) echo "Unsupported arch for docker CLI: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://download.docker.com/linux/static/stable/${docker_arch}/docker-${DOCKER_VERSION}.tgz" \
        | tar -xz -C /tmp; \
    mv /tmp/docker/docker /usr/local/bin/docker; \
    rm -rf /tmp/docker; \
    mkdir -p /usr/local/lib/docker/cli-plugins; \
    curl -fsSL -o /usr/local/lib/docker/cli-plugins/docker-compose \
        "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${compose_arch}"; \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose; \
    docker --version; \
    docker compose version

# Create non-root user with sudo access (delete existing node user first)
RUN userdel -r node 2>/dev/null || true \
    && useradd -m -u 1000 -s /bin/bash ralph \
    && echo "ralph ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ralph \
    && chmod 0440 /etc/sudoers.d/ralph

# Copy entrypoint script (as root, before switching user)
# Convert CRLF to LF (Windows line endings break shebang)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Create workspace and .claude directories
RUN mkdir -p /workspace /home/ralph/.claude \
    && chown -R ralph:ralph /workspace /home/ralph/.claude

# Copy container-specific Claude config from container-claude/
COPY --chown=ralph:ralph container-claude/agents/ /home/ralph/.claude/agents/

# Copy the stop-and-exit hook (referenced by entrypoint.sh settings.json).
# Convert CRLF to LF — Windows line endings break the shebang on Linux.
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
