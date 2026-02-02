#!/bin/bash
# Output JSON to tell Claude to stop, then terminate the process
echo '{"continue": false}'

# Kill the Claude process to actually exit
# PPID is the parent process (Claude CLI)
kill -TERM $PPID 2>/dev/null || true

exit 0
