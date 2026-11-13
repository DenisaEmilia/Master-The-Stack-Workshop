#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
GATE=08
# A previous successful run must not hide a broken release script.
# Preserve a pre-existing tag before temporarily removing it; restore it on failure.
previous="$(docker image inspect --format '{{.Id}}' "$ESCAPE_FINAL_IMAGE" 2>/dev/null || true)"
backup="${ESCAPE_REPOSITORY}:backup-${ESCAPE_SCOPE}-$$"
restore_previous() {
  if [[ -n "$previous" ]]; then
    docker tag "$backup" "$ESCAPE_FINAL_IMAGE"
    docker image rm "$backup" >/dev/null
  fi
}
if [[ -n "$previous" ]]; then
  docker tag "$ESCAPE_FINAL_IMAGE" "$backup"
  trap restore_previous EXIT
  docker image rm "$ESCAPE_FINAL_IMAGE" >/dev/null
fi
bash "$ESCAPE_ROOT/scripts/release.sh" || fail 'The release script failed. Inspect scripts/release.sh.'
actual="$(docker image inspect --format '{{.Id}}' "$ESCAPE_FINAL_IMAGE" 2>/dev/null)" || fail "The release script did not create $ESCAPE_FINAL_IMAGE. Inspect its tag command."
expected="$(docker image inspect --format '{{.Id}}' "$ESCAPE_IMAGE")"
[[ "$actual" == "$expected" ]] || fail 'The final tag points to a different image than the tested challenge image.'
trap - EXIT
if [[ -n "$previous" ]]; then docker image rm "$backup" >/dev/null; fi
pass "Verified the real Docker artifact: $ESCAPE_FINAL_IMAGE"
