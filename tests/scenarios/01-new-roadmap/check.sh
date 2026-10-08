#!/usr/bin/env bash
set -e
R=learning/java/roadmap.md
[ -f "$R" ]
[ "$(grep -c '^## Level' "$R")" = 4 ]
grep -q '^last-checked: [0-9]\{4\}-' "$R"
[ "$(grep -cE '^- \[ \] [0-9]{2} ' "$R")" -ge 20 ]
grep -q '^| java ' learning/index.md
