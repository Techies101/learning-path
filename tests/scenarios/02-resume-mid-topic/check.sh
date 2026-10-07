#!/usr/bin/env bash
set -e
diff learning/java/roadmap.md .orig/learning/java/roadmap.md
grep -q '^| java ' learning/index.md
