#!/usr/bin/env bash
set -e
R=learning/java/roadmap.md
grep -qx -- '- \[x\] 05 Streams' $R || { echo "done line missing"; exit 1; }
# not an override, no leftover note
if grep -q '05 Streams (override)' $R; then echo "marked as override"; exit 1; fi
# the learner's code is untouched
D=learning/java/code/05-streams
diff -r $D .orig/$D || { echo "code changed"; exit 1; }
diff <(grep -v '05 Streams' $R) <(grep -v '05 Streams' .orig/$R) || { echo "other roadmap lines changed"; exit 1; }
# index: java row Progress done-count = fixture done-count + 1 (read from the fixture)
before=$(grep -E '^\| java ' .orig/learning/index.md | awk -F'|' '{gsub(/ /,"",$3); split($3,a,"/"); print a[1]}')
after=$(grep -E '^\| java ' learning/index.md | awk -F'|' '{gsub(/ /,"",$3); split($3,a,"/"); print a[1]}')
total=$(grep -E '^\| java ' learning/index.md | awk -F'|' '{gsub(/ /,"",$3); split($3,a,"/"); print a[2]}')
rtotal=$(grep -Ec '^- \[.\] [0-9]+ ' $R)
[ -n "$before" ] && [ -n "$after" ] || { echo "cannot parse index"; exit 1; }
[ "$after" -eq $((before + 1)) ] || { echo "progress $before -> $after, expected +1"; exit 1; }
[ "$total" -eq "$rtotal" ] || { echo "index total $total != roadmap topics $rtotal"; exit 1; }
