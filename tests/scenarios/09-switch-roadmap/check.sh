#!/usr/bin/env bash
set -e
diff learning/java/roadmap.md .orig/learning/java/roadmap.md
[ -f learning/python/roadmap.md ]
today=$(date +%F)
row() { grep "^| $1 " learning/index.md; }
field() { row "$1" | awk -F'|' -v n="$2" '{gsub(/^ +| +$/,"",$n); print $n}'; }
total() { grep -cE '^- \[[ x~]\] [0-9]{2} ' "learning/$1/roadmap.md"; }
done_() { grep -cE '^- \[x\] [0-9]{2} ' "learning/$1/roadmap.md"; }
for s in java python; do
  [ "$(field $s 3)" = "$(done_ $s)/$(total $s)" ] || { echo "progress mismatch for $s"; exit 1; }
  [ "$(field $s 5)" = "$today" ] || { echo "last active not today for $s"; exit 1; }
done
[ "$(field java 3)" = "3/10" ]
# java was touched last: its row must come first
[ "$(grep -n '^| java ' learning/index.md | cut -d: -f1)" -lt "$(grep -n '^| python ' learning/index.md | cut -d: -f1)" ]
[ "$(field java 5)" \> "$(field python 5)" ] || [ "$(field java 5)" = "$(field python 5)" ]
