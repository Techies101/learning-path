#!/usr/bin/env bash
# Rebuilds the fixture/ and .orig/ of every scenario that uses _shared/java-streams.
# Single source of truth: _shared/java-streams/. Run from anywhere; commit the output.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCEN="$(dirname "$HERE")"
SRC="$HERE/java-streams"
CODE=learning/java/code/05-streams

build() { # <scenario> <variation>
  local d="$SCEN/$1"
  rm -rf "$d/fixture"
  mkdir -p "$d/fixture"
  cp -a "$SRC/." "$d/fixture/"
  case "$2" in
    full) ;;
    empty) find "$d/fixture/$CODE" -name '*.java' -delete ;;
    relocated)
      mkdir -p "$d/fixture/learning/java/elsewhere"
      mv "$d/fixture/$CODE" "$d/fixture/learning/java/elsewhere/streams" ;;
    compile-error)
      sed -i 's/^\(        return totals\);/\1/' "$d/fixture/$CODE/src/main/java/ClaimTotals.java"
      grep -q '^        return totals$' "$d/fixture/$CODE/src/main/java/ClaimTotals.java" ;;
  esac
  cp -a "$d/fixture" "$d/.orig.tmp" && mv "$d/.orig.tmp" "$d/fixture/.orig"
}

# Task 5 scenarios
build 05-review-hints full
build 06-show-one-fix full
build 07-empty-folder empty
build 16-relocated-folder relocated
build 19-compile-error compile-error
