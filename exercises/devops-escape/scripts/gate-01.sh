#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
GATE=01
[[ -f "$ESCAPE_ROOT/deployment-info.json" ]] || fail 'deployment-info.json is missing from exercises/devops-escape. Find the required artifact in the mission briefing.'
python3 - "$ESCAPE_ROOT/deployment-info.json" <<'PY' || fail 'deployment-info.json must be valid JSON with the required appName and version. Read Mission 1.'
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8-sig"))
    assert isinstance(data, dict) and data.get("appName") == "workshop-app" and data.get("version") == "1.0.0"
except (ValueError, OSError, AssertionError):
    sys.exit(1)
PY
pass 'The release artifact is present and valid.'
