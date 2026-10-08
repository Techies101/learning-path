#!/usr/bin/env bash
# Usage: run-scenario.sh <scenario-dir>
# Runs prompt-N.txt turns through headless claude in a temp work folder, then
# check.sh (cwd = work folder), then an optional LLM judge (judge.md).
# Prints "PASS <name>" or "FAIL <name>: <reason>"; exit 0/1.
# Side effect: creates the symlink ~/.claude/skills/learning-path -> this checkout's
# skill/learning-path if it is absent (see README, "Running the tests").
set -euo pipefail

[ $# -eq 1 ] || { echo "usage: $0 <scenario-dir>" >&2; exit 2; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$HERE")"
SCEN="$(cd "$1" && pwd)"
NAME="$(basename "$SCEN")"
TOOLS="Bash Read Write Edit Glob Grep WebSearch WebFetch Skill"

WORK=""
fail() {
  if [ -n "$WORK" ]; then echo "FAIL $NAME: $1 (work folder: $WORK)"; else echo "FAIL $NAME: $1"; fi
  exit 1
}

# Install the skill under test: the installed entry must be a symlink to THIS checkout.
SKILL_SRC="$(cd -P "$REPO/skill/learning-path" 2>/dev/null && pwd -P)" \
  || fail "skill folder $REPO/skill/learning-path not found"
SKILL_LINK="$HOME/.claude/skills/learning-path"
if [ ! -e "$SKILL_LINK" ] && [ ! -L "$SKILL_LINK" ]; then
  mkdir -p "$HOME/.claude/skills"
  ln -s "$SKILL_SRC" "$SKILL_LINK" || fail "could not create symlink $SKILL_LINK"
elif [ -L "$SKILL_LINK" ] && TARGET="$(cd -P "$SKILL_LINK" 2>/dev/null && pwd -P)" \
     && [ "$TARGET" = "$SKILL_SRC" ]; then
  : # already links to this checkout
else
  if [ -L "$SKILL_LINK" ] && [ ! -e "$SKILL_LINK" ]; then
    what="a dangling symlink"
  elif [ -L "$SKILL_LINK" ]; then
    what="a symlink to ${TARGET:-another folder}"
  else
    what="a copied folder or file, not a symlink"
  fi
  fail "$SKILL_LINK is $what; the tests must run against $SKILL_SRC. Move it aside (mv \"$SKILL_LINK\" \"$SKILL_LINK.bak\") and rerun; the runner then links this checkout"
fi

WORK="$(mktemp -d)"
# Never touch the learner's real workspace config (see SKILL.md, First run).
export LEARNING_PATH_CONFIG="$WORK/.learning-path-workspace.txt"
[ -d "$SCEN/fixture" ] && cp -a "$SCEN/fixture/." "$WORK/"
# Fixture dates are tokenized so they never go stale; stamp them with today.
# Portable (no sed -i) and failures are not swallowed.
TODAY="$(date +%F)"
STAMP_TMP="$(mktemp)"
while IFS= read -r -d '' f; do
  grep -qI "__TODAY__" "$f" || continue
  sed "s/__TODAY__/$TODAY/g" "$f" > "$STAMP_TMP" && cat "$STAMP_TMP" > "$f" \
    || fail "could not stamp __TODAY__ in $f"
done < <(find "$WORK" -type f -print0)
rm -f "$STAMP_TMP"
if grep -rlI "__TODAY__" "$WORK" >/dev/null 2>&1; then
  fail "__TODAY__ left in fixture files: $(grep -rlI "__TODAY__" "$WORK" | head -n 3 | tr '\n' ' ')"
fi
TRANSCRIPT="$WORK/transcript.txt"
: > "$TRANSCRIPT"

FLAGS=()
[ -f "$SCEN/flags.txt" ] && read -r -a FLAGS < "$SCEN/flags.txt" || true

# Prompts are prompt-1.txt .. prompt-N.txt; walk them by number (no ls, no sort -V).
total=0
for p in "$SCEN"/prompt-*.txt; do [ -e "$p" ] && total=$((total + 1)); done
[ "$total" -gt 0 ] || fail "no prompt-N.txt files in scenario"
seq_n=0
while [ -f "$SCEN/prompt-$((seq_n + 1)).txt" ]; do seq_n=$((seq_n + 1)); done
[ "$seq_n" -eq "$total" ] || fail "prompt files must be numbered prompt-1.txt..prompt-N.txt without gaps ($total found, $seq_n in sequence)"
n=1
while [ -f "$SCEN/prompt-$n.txt" ]; do
  prompt="$SCEN/prompt-$n.txt"
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
