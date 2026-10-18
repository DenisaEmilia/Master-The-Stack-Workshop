#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

for file in index.html Dockerfile .dockerignore .github/workflows/ci-cd.yml scripts/smoke-test.sh scripts/update-container.sh scripts/update-container.ps1 README.md WORKSHOP.md; do
  if [[ ! -s "$file" ]]; then
    echo "ERROR: required file is missing or empty: $file" >&2
    exit 1
  fi
done
grep -Fq '<h1>From Code to Container</h1>' index.html || {
  echo 'ERROR: index.html is missing the expected page heading.' >&2
  exit 1
}
# Accept any numbered version so the Version 2 exercise still passes CI.
grep -Eq 'id="app-version">Version [0-9]+</span>' index.html || {
  echo 'ERROR: index.html is missing a numbered app-version marker.' >&2
  exit 1
}
for script in scripts/*.sh; do
  bash -n "$script"
done
echo "PASS: required files, page heading, version marker, and Bash syntax."
