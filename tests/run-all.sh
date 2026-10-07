#!/usr/bin/env bash
# Usage: run-all.sh [--repeat N]   (default 2)
# Runs every tests/scenarios/*/ (skipping 00-* and _*) N times; exit 0 only if all pass.
set -euo pipefail

REPEAT=2
if [ "${1:-}" = "--repeat" ]; then
  REPEAT="${2:?--repeat needs a number}"
fi
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

status=0
for dir in "$HERE"/scenarios/*/; do
  name="$(basename "$dir")"
  case "$name" in 00-*|_*) continue ;; esac
  for i in $(seq 1 "$REPEAT"); do
    echo "[run $i/$REPEAT] $name"
    bash "$HERE/run-scenario.sh" "$dir" || status=1
  done
done
exit $status
