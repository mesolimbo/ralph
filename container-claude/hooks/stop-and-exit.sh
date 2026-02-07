#!/bin/bash
# Output JSON to tell Claude to stop
echo '{"continue": false}'

# Kill the Claude process so the entrypoint loop can restart it.
# Backgrounded with a delay to avoid racing against hook processing.
(sleep 1 && kill -TERM $PPID 2>/dev/null) &

exit 0
