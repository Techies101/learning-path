#!/usr/bin/env bash
set -e
diff learning/java/roadmap.md .orig/learning/java/roadmap.md || { echo "roadmap changed"; exit 1; }
grep -qx -- '- \[?? 07 Generics' learning/java/roadmap.md || { echo "bad line missing"; exit 1; }
