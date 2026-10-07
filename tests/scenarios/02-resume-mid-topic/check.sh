#!/usr/bin/env bash
set -e
diff learning/java/roadmap.md .orig/learning/java/roadmap.md
# fixture truth: 3 of 10 topics done, current topic Collections
grep -Eq '^\| java +\| 3/10 +\| Collections +\| [0-9]{4}-[0-9]{2}-[0-9]{2} +\|' learning/index.md
