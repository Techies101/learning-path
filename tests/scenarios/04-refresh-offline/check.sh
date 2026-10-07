#!/usr/bin/env bash
set -e
diff learning/java/roadmap.md .orig/learning/java/roadmap.md
grep -q '^last-checked: 2000-01-01$' learning/java/roadmap.md
