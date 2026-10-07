#!/usr/bin/env bash
set -e

S=learning/java/specs/05-streams.md
[ -f "$S" ] || { echo "missing $S"; exit 1; }
for h in "^# 05 Streams: .+" "^## Goal" "^## Requirements" "^## Acceptance Criteria" "^## Folder" "^## Suggested Names" "^## How to Run"; do
  grep -Eq "$h" "$S" || { echo "spec missing heading $h"; exit 1; }
done
grep -Eq "^- \[ \] AC1" "$S" || { echo "no AC1 checkbox"; exit 1; }
F=$(awk "/^## Folder/{f=1;next} /^## /{f=0} f&&NF{print;exit}" "$S" | sed "s/[[:space:]]*(.*//;s/[[:space:]]*\$//")
[ "$F" = "code/05-streams/" ] || { echo "Folder line is [$F]"; exit 1; }
grep -Eq "^- \[~\] 05 Streams .*stage: build, spec: specs/05-streams.md, folder: code/05-streams/" learning/java/roadmap.md || { echo "roadmap line wrong"; grep 05 learning/java/roadmap.md; exit 1; }
[ -d learning/java/code/05-streams ] || { echo "no folder"; exit 1; }

diff learning/java/code/05-streams/Notes.txt .orig/learning/java/code/05-streams/Notes.txt || { echo "Notes.txt changed"; exit 1; }
