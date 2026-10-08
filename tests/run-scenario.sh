#!/usr/bin/env bash
# Usage: run-scenario.sh <scenario-dir>
# Runs prompt-N.txt turns through headless claude in a temp work folder, then
# check.sh (cwd = work folder), then an optional LLM judge (judge.md).
# Prints "PASS <name>" or "FAIL <name>: <reason>"; exit 0/1.
set -euo pipefail

[ $# -eq 1 ] || { echo "usage: $0 <scenario-dir>" >&2; exit 2; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$HERE")"
SCEN="$(cd "$1" && pwd)"
NAME="$(basename "$SCEN")"
TOOLS="Bash Read Write Edit Glob Grep WebSearch WebFetch Skill"

# Install the skill for tests (only once the skill exists, and never overwrite).
if [ -d "$REPO/skill/learning-path" ] && [ ! -e "$HOME/.claude/skills/learning-path" ]; then
  mkdir -p "$HOME/.claude/skills"
  ln -s "$REPO/skill/learning-path" "$HOME/.claude/skills/learning-path"
fi

WORK="$(mktemp -d)"
[ -d "$SCEN/fixture" ] && cp -a "$SCEN/fixture/." "$WORK/"
# Fixture dates are tokenized so they never go stale; stamp them with today.
TODAY="$(date +%F)"
find "$WORK" -type f -exec grep -lI "__TODAY__" {} + 2>/dev/null | while read -r f; do sed -i "s/__TODAY__/$TODAY/g" "$f"; done || true
TRANSCRIPT="$WORK/transcript.txt"
: > "$TRANSCRIPT"

fail() { echo "FAIL $NAME: $1 (work folder: $WORK)"; exit 1; }

FLAGS=()
[ -f "$SCEN/flags.txt" ] && read -r -a FLAGS < "$SCEN/flags.txt" || true

n=1
for prompt in $(ls "$SCEN"/prompt-*.txt 2>/dev/null | sort -V); do
  CONT=()
  [ "$n" -gt 1 ] && CONT=(--continue)
  {
    echo "=== TURN $n ==="
    echo "--- user ---"; cat "$prompt"; echo "--- claude ---"
  } >> "$TRANSCRIPT"
  (cd "$WORK" && claude -p "$(cat "$prompt")" --permission-mode acceptEdits \
      --allowedTools "$TOOLS" ${FLAGS[@]+"${FLAGS[@]}"} ${CONT[@]+"${CONT[@]}"}) \
    >> "$TRANSCRIPT" 2>&1 || fail "claude failed on turn $n"
  echo >> "$TRANSCRIPT"
  n=$((n + 1))
done
[ "$n" -gt 1 ] || fail "no prompt-N.txt files in scenario"

if [ -f "$SCEN/check.sh" ]; then
  (cd "$WORK" && bash "$SCEN/check.sh") || fail "check.sh failed"
fi

if [ -f "$SCEN/judge.md" ]; then
  JUDGE_OUT="$WORK/judge-output.txt"
  if ! (cat "$HERE/judge-prompt.md"; printf '\n## Criteria\n\n'; cat "$SCEN/judge.md"; \
        printf '\n## Transcript\n\n'; cat "$TRANSCRIPT") \
      | (cd "$WORK" && claude -p) > "$JUDGE_OUT" 2>&1; then
    fail "judge call failed (see $JUDGE_OUT)"
  fi
  LAST="$(grep -v '^[[:space:]]*$' "$JUDGE_OUT" | tail -n 1 || true)"
  [ "$LAST" = "VERDICT: PASS" ] || fail "judge: ${LAST:-<empty>} (see $JUDGE_OUT)"
fi

echo "PASS $NAME"
