#!/bin/bash
# Signal the entrypoint to kill claude and restart the loop.
# The hook cannot reliably kill claude from within (PPID may not resolve to
# claude, and Claude Code cleans up hook child processes — even backgrounded
# ones). Instead we drop a marker file that the entrypoint polls for.
touch /tmp/ralph-stop
echo '{"continue": false}'
exit 0
