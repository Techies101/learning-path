#!/usr/bin/env bash
set -e
S=learning/java/specs/05-streams.md
F=$(awk '/^## Folder/{f=1;next} /^## /{f=0} f&&NF{print;exit}' "$S" | sed 's/[[:space:]]*(.*//;s/[[:space:]]*$//')
[ "$F" = "elsewhere/streams/" ] || { echo "spec Folder line is [$F]"; exit 1; }
grep -Eq '^- \[~\] 05 Streams .*stage: review, spec: specs/05-streams.md, folder: elsewhere/streams/\)' learning/java/roadmap.md || { echo "roadmap line wrong"; grep 05 learning/java/roadmap.md; exit 1; }
diff learning/java/elsewhere/streams/src/main/java/ClaimTotals.java .orig/learning/java/elsewhere/streams/src/main/java/ClaimTotals.java || { echo "code changed"; exit 1; }
