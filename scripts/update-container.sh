#!/usr/bin/env bash
set -euo pipefail

if (( $# > 2 )); then
  echo "Usage: bash scripts/update-container.sh [USERNAME|IMAGE] [TAG]" >&2
  exit 1
fi
image="${1:-${DOCKERHUB_USERNAME:-}}"
tag="${2:-latest}"
if [[ -z "$image" || "$image" == *[[:space:]]* || "$image" == -* || "$image" == *@* || "${image##*/}" == *:* || ! "$tag" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$ ]]; then
  echo "ERROR: supply a Docker Hub username or an untagged image, then an optional tag." >&2
  echo "Example: bash scripts/update-container.sh yourname sha-a1b2c3d" >&2
  exit 1
fi
[[ "$image" == */* ]] || image="$image/workshop-app"
reference="$image:$tag"
name=workshop-app
label=com.from-code-to-container.workshop
command -v docker >/dev/null || { echo "ERROR: install Docker Desktop first." >&2; exit 1; }
command -v curl >/dev/null || { echo "ERROR: curl is needed for the HTTP readiness check." >&2; exit 1; }
docker info >/dev/null || { echo "ERROR: start Docker Desktop (Linux containers)." >&2; exit 1; }

# Identify collisions before touching any existing container.
existing="$(docker container ls -a --filter "name=^/${name}$" --format '{{.Names}}')"
if [[ -n "$existing" ]]; then
  owner="$(docker inspect --format '{{index .Config.Labels "com.from-code-to-container.workshop"}}' "$name")"
  if [[ "$owner" != true ]]; then
    echo "ERROR: '$name' exists without the workshop label. Inspect it and choose whether to remove or rename it yourself." >&2
    exit 1
  fi
fi
echo "Pulling $reference before replacing the current container..."
docker pull "$reference" || { echo "ERROR: pull failed; the previous container was kept. Check the public image name and tag." >&2; exit 1; }
if [[ -n "$existing" ]]; then
  docker stop "$name"
  docker rm "$name"
fi
docker run -d --name "$name" --label "$label=true" -p 127.0.0.1:8080:80 "$reference" || {
  echo "ERROR: container could not start. Check whether port 8080 is in use." >&2
  exit 1
}
if ! bash "$(dirname "${BASH_SOURCE[0]}")/smoke-test.sh" http://localhost:8080; then
  docker logs "$name" >&2
  echo "ERROR: container started but failed its HTTP check. Inspect: docker logs $name" >&2
  exit 1
fi
echo "Running $reference at http://localhost:8080"
