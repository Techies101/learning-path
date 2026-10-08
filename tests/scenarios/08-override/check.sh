#!/usr/bin/env bash
set -e
R=learning/java/roadmap.md
grep -qx -- '- \[x\] 05 Streams (override)' $R || { echo "override line missing"; exit 1; }
# the learner's code is untouched
D=learning/java/code/05-streams
diff -r $D .orig/$D || { echo "code changed"; exit 1; }
# other lines unchanged
diff <(grep -v '05 Streams' $R) <(grep -v '05 Streams' .orig/$R) || { echo "other roadmap lines changed"; exit 1; }
# index: 5 of 9 done now
grep -Eq '^\| java +\| 5/9 +\| Exceptions +\| [0-9]{4}-[0-9]{2}-[0-9]{2} +\|' learning/index.md || { echo "index row wrong"; exit 1; }
