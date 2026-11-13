#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
GATE=03
# Default: docker build -t escape-room:challenge exercises/devops-escape
docker build -t "$ESCAPE_IMAGE" "$ESCAPE_ROOT" || fail 'Docker build failed. Compare the COPY source in the exercise Dockerfile with the files in its build context.'
pass 'The actual challenge image built successfully.'
