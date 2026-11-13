#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
GATE=06
python3 - "$ESCAPE_ROOT/release-config.json" <<'PY' || fail 'release-config.json has an invalid releaseCode (or invalid JSON). Decode pirate-note.txt; this is a puzzle, not a credential.'
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8-sig"))
    assert isinstance(data, dict) and data.get("releaseCode") == "parrot"
except (ValueError, OSError, AssertionError):
    sys.exit(1)
PY
pass 'Captain Dockerbeard accepts the release code.'
