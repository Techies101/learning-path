#!/usr/bin/env bash
# Usage: run-all.sh [--repeat N]   (default 2)
# Runs every tests/scenarios/*/ (skipping 00-* and _*) N times; exit 0 only if all pass
# and at least one scenario ran.
set -euo pipefail

usage() { echo "usage: $0 [--repeat N]   (N a positive integer)" >&2; exit 2; }

REPEAT=2
case $# in
  0) ;;
  2) [ "$1" = "--repeat" ] || usage
     [[ "$2" =~ ^[1-9][0-9]*$ ]] || usage
     REPEAT="$2" ;;
  *) usage ;;
esac
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

status=0
ran=0
for dir in "$HERE"/scenarios/*/; do
  name="$(basename "$dir")"
  case "$name" in 00-*|_*) continue ;; esac
  for i in $(seq 1 "$REPEAT"); do
    echo "[run $i/$REPEAT] $name"
    ran=$((ran + 1))
    bash "$HERE/run-scenario.sh" "$dir" || status=1
  done
done
if [ "$ran" -eq 0 ]; then
  echo "no scenarios ran" >&2
  exit 1
fi
exit $status
