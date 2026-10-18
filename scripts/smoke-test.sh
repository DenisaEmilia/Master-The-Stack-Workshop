#!/usr/bin/env bash
set -euo pipefail
url="${1:-http://localhost:8080}"
response="$(mktemp)"
trap 'rm -f "$response"' EXIT

echo "Waiting for Nginx at $url (up to 30 attempts)..."
ready=false
for ((attempt=1; attempt<=30; attempt++)); do
  if curl --fail --silent --show-error --connect-timeout 2 --max-time 3 "$url" -o "$response"; then
    ready=true
    break
  fi
  echo "Attempt $attempt/30 did not receive a successful HTTP response."
  sleep 1
done
if [[ "$ready" != true ]]; then
  echo "ERROR: Nginx did not become ready at $url." >&2
  exit 1
fi
grep -Fq '<h1>From Code to Container</h1>' "$response" || {
  echo "ERROR: HTTP response is missing the workshop heading." >&2
  exit 1
}
grep -Eq 'id="app-version">Version [0-9]+</span>' "$response" || {
  echo "ERROR: HTTP response is missing a numbered version marker." >&2
  exit 1
}
echo "PASS: HTTP response contains the expected heading and version marker."
