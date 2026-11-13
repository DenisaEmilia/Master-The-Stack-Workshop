#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
if docker container inspect "$ESCAPE_CONTAINER" >/dev/null 2>&1; then
  owner="$(docker inspect --format '{{index .Config.Labels "devops.escape-room"}}' "$ESCAPE_CONTAINER")"
  if [[ "$owner" != "$ESCAPE_SCOPE" ]]; then
    echo 'ERROR: refusing to remove an unrelated container with the challenge name.' >&2
    exit 1
  fi
  docker rm --force "$ESCAPE_CONTAINER" >/dev/null
fi
