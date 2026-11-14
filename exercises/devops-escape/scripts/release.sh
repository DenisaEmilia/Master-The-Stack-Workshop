#!/usr/bin/env bash
# Student-owned release command. Prepare a local tag; never push an image.
set -euo pipefail
docker tag "$ESCAPE_IMAGE" "${ESCAPE_REPOSITORY}:escape-room:v1.0.0"
