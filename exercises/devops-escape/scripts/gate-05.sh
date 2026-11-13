#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
GATE=05
require_owned_container
body="$(mktemp)"
trap 'rm -f "$body"' EXIT
status="$(curl --noproxy 127.0.0.1 --silent --show-error --output "$body" --write-out '%{http_code}' --connect-timeout 2 --max-time 5 http://127.0.0.1:8080)" || fail 'HTTP request failed. Complete Gate 4 before testing the page.'
[[ "$status" == 200 ]] || fail "Expected HTTP 200, received $status."
grep -Fq 'Hello from Version 2!' "$body" || fail 'HTTP 200 is not enough: the served page must say Hello from Version 2! Inspect the exercise index.html, then rebuild through the pipeline.'
pass 'The actual HTTP response contains the required Version 2 greeting.'
