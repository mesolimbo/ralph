.PHONY: build build-test test ralph clean help

# Load environment variables from .env file if it exists
-include .env
export

# Docker image names
IMAGE_NAME := ralph
TEST_IMAGE := ralph-test

# Default values
MAX_ITERATIONS ?= 0

# Build the runtime Docker image
build:
	docker build --target runtime -t $(IMAGE_NAME) .

# Build the test Docker image
build-test:
	docker build --target test -t $(TEST_IMAGE) .

# Run tests in Docker
test: build-test
	docker run --rm $(TEST_IMAGE)

# Run ralph in Docker with mounted workspace
# Usage: make ralph WORKSPACE=/path/to/workspace [MAX_ITERATIONS=5]
ralph: build
ifndef WORKSPACE
	$(error WORKSPACE is not set. Usage: make ralph WORKSPACE=/path/to/workspace [MAX_ITERATIONS=5])
endif
ifndef ANTHROPIC_API_KEY
	$(error ANTHROPIC_API_KEY is not set. Add it to .env file or export it)
endif
	docker run --rm -it \
		-e ANTHROPIC_API_KEY="$(ANTHROPIC_API_KEY)" \
		-e RALPH_MAX_ITERATIONS="$(MAX_ITERATIONS)" \
		-v "$(WORKSPACE):/workspace" \
		$(IMAGE_NAME)


# Clean up Docker images
clean:
	-docker rmi $(IMAGE_NAME) $(TEST_IMAGE) 2>/dev/null || true

# Show help
help:
	@echo "Ralph - Dockerized Claude in Dangerously Mode"
	@echo ""
	@echo "Usage:"
	@echo "  make build                    Build the Docker image"
	@echo "  make test                     Run tests in Docker"
	@echo "  make ralph WORKSPACE=<path>   Run ralph with mounted workspace"
	@echo "  make clean                    Remove Docker images"
	@echo ""
	@echo "Options:"
	@echo "  WORKSPACE=<path>       Directory to mount as /workspace (required)"
	@echo "                         Must contain a prompt.md file"
	@echo "  MAX_ITERATIONS=<n>     Limit loop iterations (default: 0 = unlimited)"
	@echo ""
	@echo "Examples:"
	@echo "  make ralph WORKSPACE=./myproject"
	@echo "  make ralph WORKSPACE=./myproject MAX_ITERATIONS=5"
	@echo ""
	@echo "Requirements:"
	@echo "  - ANTHROPIC_API_KEY in .env file or environment"
	@echo "  - WORKSPACE must contain prompt.md"
