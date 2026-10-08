#!/usr/bin/env bash
set -e
D=learning/java/code/05-streams
diff learning/java/roadmap.md .orig/learning/java/roadmap.md || { echo "roadmap changed"; exit 1; }
diff $D/pom.xml .orig/$D/pom.xml || { echo "pom changed"; exit 1; }
n=$(find $D -name '*.java' | wc -l)
[ "$n" -eq 0 ] || { echo "skill created java files"; exit 1; }
