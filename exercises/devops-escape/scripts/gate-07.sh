#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
GATE=07
python3 - "$ESCAPE_ROOT/release-config.json" <<'PY' || fail 'release-config.json must be valid JSON with the required production environment. Keep the pirate releaseCode intact.'
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8-sig"))
    assert isinstance(data, dict) and data.get("environment") == "production"
except (ValueError, OSError, AssertionError):
    sys.exit(1)
PY
pass 'The release targets the required environment.'
