#!/usr/bin/env bash
set -e
diff learning/java/roadmap.md .orig/learning/java/roadmap.md
[ -f learning/python/roadmap.md ]
grep -q '^| java ' learning/index.md
grep -q '^| python ' learning/index.md
# java must be listed above python (newest Last active first)
[ "$(grep -n '^| java ' learning/index.md | cut -d: -f1)" -lt "$(grep -n '^| python ' learning/index.md | cut -d: -f1)" ]
