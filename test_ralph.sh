#!/bin/bash
# Simple tests for ralph container setup

set -e

echo "=== Ralph Container Tests ==="

# Test 1: Check sudo access
echo -n "Test 1: Sudo access... "
if sudo whoami | grep -q "root"; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 2: Check Claude CLI is installed
echo -n "Test 2: Claude CLI installed... "
if command -v claude &> /dev/null; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 3: Check entrypoint exists
echo -n "Test 3: Entrypoint script exists... "
if [ -x /usr/local/bin/entrypoint.sh ]; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 4: Check workspace directory exists
echo -n "Test 4: Workspace directory exists... "
if [ -d /workspace ]; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 5: Check user is ralph
echo -n "Test 5: Running as ralph user... "
if [ "$(whoami)" = "ralph" ]; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 6: Check bash is available
echo -n "Test 6: Bash available... "
if command -v bash &> /dev/null; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 7: Check Playwright Chromium browser installed
echo -n "Test 7: Playwright Chromium installed... "
CHROME_BIN="$(find "${PLAYWRIGHT_BROWSERS_PATH}" -path "*/chrome-linux64/chrome" -type f 2>/dev/null | head -1)"
if [ -n "$CHROME_BIN" ] && [ -x "$CHROME_BIN" ]; then
    echo "PASS"
else
    echo "FAIL (no chrome binary found under ${PLAYWRIGHT_BROWSERS_PATH})"
    exit 1
fi

# Test 8: Check Chromium version executes
echo -n "Test 8: Chromium version check... "
if "$CHROME_BIN" --version &> /dev/null; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Test 9: Check Playwright MCP package installed
echo -n "Test 9: Playwright MCP package installed... "
if npm ls -g @playwright/mcp &> /dev/null; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

echo ""
echo "=== All 9 tests passed ==="
