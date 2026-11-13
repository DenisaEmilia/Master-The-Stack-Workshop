#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
trap 'bash "$ESCAPE_ROOT/scripts/cleanup.sh"' EXIT
results=(skipped skipped skipped skipped skipped skipped skipped skipped)
exit_status=0
for number in {1..8}; do
  printf -v gate '%02d' "$number"
  echo "===== Gate $gate ====="
  if bash "$ESCAPE_ROOT/scripts/gate-${gate}.sh"; then
    results[$((number-1))]=success
  else
    results[$((number-1))]=failure
    exit_status="$number"
    break
  fi
done
bash "$ESCAPE_ROOT/scripts/report.sh" "${results[@]}"
exit "$exit_status"
