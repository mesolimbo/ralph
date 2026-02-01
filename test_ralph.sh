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

echo ""
echo "=== All tests passed ==="
