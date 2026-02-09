#!/bin/bash
# Signal the entrypoint to kill Claude and restart the loop.
# The hook can't reliably kill Claude from within (PPID may not
# resolve correctly, and Claude Code cleans up hook child processes).
# Instead, write a marker file that the entrypoint watches for.
touch /tmp/ralph-stop
echo '{"continue": false}'
exit 0
