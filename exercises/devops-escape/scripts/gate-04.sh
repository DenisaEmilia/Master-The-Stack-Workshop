#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
GATE=04
bash "$ESCAPE_ROOT/scripts/cleanup.sh" || fail 'Safe cleanup failed. Check for a container name collision.'
bash "$ESCAPE_ROOT/scripts/start-container.sh" || fail 'Could not start the challenge container. Read the Docker error; check port 8080 and start-container.sh.'
require_owned_container
if ! http_ready; then
  docker logs --tail 15 "$ESCAPE_CONTAINER" >&2 || true
  fail 'No HTTP 200 at http://127.0.0.1:8080. Inspect the host:container mapping in scripts/start-container.sh and the Nginx listening port.'
fi
pass 'The container is reachable over HTTP.'
