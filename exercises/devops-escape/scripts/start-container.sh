#!/usr/bin/env bash
# Student-owned runtime configuration. Nginx uses its normal image defaults.
set -euo pipefail
docker run --detach --name "$ESCAPE_CONTAINER" \
  --label "devops.escape-room=$ESCAPE_SCOPE" \
  --publish 127.0.0.1:8080:80 "$ESCAPE_IMAGE"
