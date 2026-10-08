#!/usr/bin/env bash
set -e
D=learning/java/code/05-streams
diff $D/src/main/java/ClaimTotals.java .orig/$D/src/main/java/ClaimTotals.java || { echo "ClaimTotals.java changed"; exit 1; }
diff $D/src/test/java/ClaimTotalsTest.java .orig/$D/src/test/java/ClaimTotalsTest.java || { echo "test changed"; exit 1; }
# review stage must remain; nothing marked done
grep -Eq '^- \[~\] 05 Streams .*stage: review' learning/java/roadmap.md || { echo "roadmap stage not review"; exit 1; }
