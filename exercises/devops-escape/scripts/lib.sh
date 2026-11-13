#!/usr/bin/env bash
# Validator helpers. Students repair the artifacts, start-container.sh, and release.sh.
set -euo pipefail
ESCAPE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scope_hash="$(printf '%s' "$ESCAPE_ROOT" | sha256sum | cut -c1-12)"
export ESCAPE_SCOPE="${ESCAPE_SCOPE:-${scope_hash}-${GITHUB_RUN_ID:-local}-${GITHUB_RUN_ATTEMPT:-1}}"
export ESCAPE_CONTAINER="${ESCAPE_CONTAINER:-devops-escape-${ESCAPE_SCOPE}}"
export ESCAPE_REPOSITORY="${ESCAPE_REPOSITORY:-escape-room}"
export ESCAPE_IMAGE="${ESCAPE_REPOSITORY}:challenge"
export ESCAPE_FINAL_IMAGE="${ESCAPE_REPOSITORY}:v1.0.0"

fail() { echo "::error title=Gate ${GATE}::Gate ${GATE}: $*" >&2; exit 1; }
pass() { echo "PASS — Gate ${GATE}: $*"; }

require_owned_container() {
  local owner
  owner="$(docker inspect --format '{{index .Config.Labels "devops.escape-room"}}' "$ESCAPE_CONTAINER" 2>/dev/null)" || fail 'The challenge container is missing. Run the earlier gates first.'
  [[ "$owner" == "$ESCAPE_SCOPE" ]] || fail 'Container name collision: refusing to manage an unrelated container.'
}

http_ready() {
  local attempt status
  for ((attempt=1; attempt<=8; attempt++)); do
    status="$(curl --noproxy 127.0.0.1 --silent --output /dev/null --write-out '%{http_code}' --connect-timeout 1 --max-time 2 http://127.0.0.1:8080)" || status=000
    [[ "$status" == 200 ]] && return 0
    echo "Waiting for HTTP 200 ($attempt/8; received $status)..."
    sleep 1
  done
  return 1
}
