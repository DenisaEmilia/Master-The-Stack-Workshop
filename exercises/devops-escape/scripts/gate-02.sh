#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
GATE=02
[[ -f "$ESCAPE_ROOT/duck-answer.txt" ]] || fail 'duck-answer.txt is missing. Read duck.txt and give the reviewer an answer.'
python3 - "$ESCAPE_ROOT/duck-answer.txt" <<'PY' || fail 'The duck declined your answer. Re-read the riddle; surrounding whitespace and capitalization are allowed.'
import sys
try:
    with open(sys.argv[1], encoding="utf-8-sig") as f:
        assert f.read().strip().casefold() == "rubber duck"
except (OSError, UnicodeError, AssertionError):
    sys.exit(1)
PY
pass 'The reviewer approves.'
