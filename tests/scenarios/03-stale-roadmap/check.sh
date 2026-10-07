#!/usr/bin/env bash
set -e
O=.orig/learning/java/roadmap.md
N=learning/java/roadmap.md
# fixture sanity: the original must have done and in-progress topics
[ "$(grep -c '^- \[x\] ' "$O")" -ge 3 ]
# every original [x] and [~] line is preserved byte-for-byte
while IFS= read -r line; do
  grep -Fxq -- "$line" "$N" || { echo "missing line: $line"; exit 1; }
done < <(grep -E '^- \[[x~]\] ' "$O")
# last-checked updated to a real date, not the stale one
grep -Eq '^last-checked: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$N"
if grep -q '^last-checked: 2000-01-01$' "$N"; then echo 'last-checked not updated'; exit 1; fi
# every original topic number still present with the same name
while IFS= read -r line; do
  num=$(echo "$line" | sed -E 's/^- \[.\] ([0-9]+) .*/\1/')
  grep -Eq "^- \[.\] $num " "$N" || { echo "topic $num dropped"; exit 1; }
done < <(grep -E '^- \[.\] ' "$O")
# topic lines not in the original: either an original [ ] line plus an outdated note,
# or a new topic with a number above the original max and a trailing (new)
max=$(grep -E '^- \[.\] ' "$O" | sed -E 's/^- \[.\] ([0-9]+) .*/\1/' | sort -n | tail -1)
while IFS= read -r line; do
  grep -Fxq -- "$line" "$O" && continue
  num=$(echo "$line" | sed -E 's/^- \[.\] ([0-9]+) .*/\1/')
  if [ $((10#$num)) -le $((10#$max)) ]; then
    base=$(echo "$line" | sed -E 's/ \(outdated: .*\)$//')
    [ "$base" != "$line" ] && grep -Fxq -- "$base" "$O" && [[ "$line" == "- [ ] "* ]] || { echo "bad edit: $line"; exit 1; }
  else
    [[ "$line" == "- [ ] "* && "$line" == *" (new)" ]] || { echo "bad new topic: $line"; exit 1; }
  fi
done < <(grep -E '^- \[.\] ' "$N")
# new numbers are unique
[ -z "$(grep -E '^- \[.\] ' "$N" | sed -E 's/^- \[.\] ([0-9]+) .*/\1/' | sort | uniq -d)" ]
