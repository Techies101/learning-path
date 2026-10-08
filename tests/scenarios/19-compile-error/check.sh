#!/usr/bin/env bash
set -e
D=learning/java/code/05-streams
diff $D/src/main/java/ClaimTotals.java .orig/$D/src/main/java/ClaimTotals.java || { echo "ClaimTotals.java changed"; exit 1; }
