#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
results=("$@")
completed=0
first='None'
for i in {0..7}; do
  result="${results[$i]:-skipped}"
  if [[ "$result" == success ]]; then ((completed+=1)); fi
  if [[ "$result" == failure && "$first" == None ]]; then printf -v first 'Gate %02d' "$((i+1))"; fi
done
sha="${GITHUB_SHA:-$(git -C "$ESCAPE_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)}"
report="$(mktemp)"
trap 'rm -f "$report"' EXIT
{
  echo '# DevOps Escape Room'
  echo "Completed gates: $completed/8"
  echo "First failed gate: $first"
  echo "Commit SHA: $sha"
  echo '| Gate | Outcome |'
  echo '| --- | --- |'
  for i in {0..7}; do printf '| %02d | %s |\n' "$((i+1))" "${results[$i]:-skipped}"; done
  if [[ "$completed" == 8 ]]; then
    docker image inspect "$ESCAPE_FINAL_IMAGE" >/dev/null
    echo "Verified image tag: $ESCAPE_FINAL_IMAGE"
    echo 'CONGRATULATIONS! YOU ESCAPED THE DEVOPS PIPELINE!'
    echo 'The rubber duck approves. Captain Dockerbeard salutes you.'
  else
    echo 'Open the first failed gate, investigate, commit your repair, and push again.'
  fi
} > "$report"
cat "$report"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then cat "$report" >> "$GITHUB_STEP_SUMMARY"; fi
if [[ "$completed" == 8 ]]; then
  cat <<'VICTORY'
  +---------------------------------------+
  |        E S C A P E   C O M P L E T E    |
  |              8 / 8 GATES              |
  +---------------------------------------+
VICTORY
fi
