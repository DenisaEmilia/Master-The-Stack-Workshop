#!/usr/bin/env bash
set -euo pipefail
exercise="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec python3 "$exercise/tests/verify_progression.py"
