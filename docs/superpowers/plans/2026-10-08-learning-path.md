# learning-path Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code skill that runs a learner through any technology topic by topic: roadmap, learn + quiz, brainstorm + spec, learner builds, review, track.

**Architecture:** The skill is Markdown instructions: a controller `SKILL.md` plus three single-purpose reference files. All learner state lives in plain Markdown files (`learning/index.md`, `learning/<slug>/roadmap.md`, `specs/`) with the exact formats pinned in Task 2. Behavior is tested with scenario tests: a shell harness copies a fixture into a temp folder, runs `claude -p` headlessly with the skill installed, then runs deterministic shell checks on the resulting files and an LLM judge on the transcript.

**Tech Stack:** Claude Code skills (SKILL.md format), Bash, `claude` CLI (headless `-p` mode), Java 21+ / Maven for the review fixtures, Python 3 + pytest for the switch-roadmap scenario.

**Spec:** `docs/superpowers/specs/2026-10-08-learning-path-design.md`

## Global Constraints

- Skill name `learning-path`; installed path `~/.claude/skills/learning-path/`.
- Commands: `/learning-path <technology>`, `/learning-path`, `/learning-path refresh`, `/learning-path status`.
- Roadmaps have exactly 4 levels: Beginner, Intermediate, Advanced, Expert.
- Auto-refresh when `last-checked` is older than 30 days.
- Status markers exactly: `[ ]`, `[~]`, `[x]`, `[x] (override)`. New topics from a refresh end with `(new)`.
- Never copy, fetch, or scrape roadmap.sh content; only link `https://roadmap.sh/<slug>` when that page is known to exist.
- Never delete completed topics; never rewrite a learner file without asking, except `index.md` (derived).
- Review gives hints first; shows a fix only when asked, and only for the requested issue.
- Quiz score is never a gate. Only review pass (or explicit override) marks a topic done.
- Every scenario must pass twice in fresh sessions.

## Review Focus

1. **No interactive menu tool (headless `-p`, or AskUserQuestion absent):** the learner still needs choices. Expect a numbered plain-text menu with the same options. Test: Task 2, scenario `12-text-menu-fallback`.
2. **Same technology typed differently ("Java", "java ", "Spring Boot" vs "spring-boot"):** expect one folder, not duplicates. Test: Task 2, scenario `13-slug-normalization`.
3. **All topics in a roadmap done:** expect a completion message and a menu (`Refresh for new topics` / `Start another roadmap`), not an error or an invented topic. Test: Task 6, scenario `14-roadmap-complete`.
4. **Learner types their own idea instead of picking one:** expect a spec from their idea that still lists exact file paths. Test: Task 4, scenario `15-own-idea`.
5. **Code moved outside `code/` (learner answers "My file is somewhere else" with a path):** expect the spec's path updated and the review to run on the new path. Test: Task 5, scenario `16-relocated-file`.

---

## File Structure

```
learning-path/                         (this repo)
  skill/learning-path/
    SKILL.md                           controller: commands, state detection, step routing, menus
    references/roadmap-builder.md      build + refresh rules, roadmap.md and index.md formats
    references/spec-template.md        one-page spec format
    references/review-checklist.md     4 checks, build-first, hint-first rules
  tests/
    run-scenario.sh                    harness: one scenario -> PASS/FAIL
    run-all.sh                         runs every scenario N times
    judge-prompt.md                    instructions for the LLM judge
    scenarios/NN-name/
      prompt-1.txt [prompt-2.txt ...]  turns, run in order with --continue
      fixture/                         copied into the temp work folder (optional)
      check.sh                         deterministic assertions, run in work folder; exit 0 = pass
      judge.md                         transcript criteria for the LLM judge (optional)
      flags.txt                        extra claude CLI flags (optional)
  README.md                            install + usage
```

---

### Task 1: Test harness

**Files:**
- Create: `tests/run-scenario.sh`, `tests/run-all.sh`, `tests/judge-prompt.md`
- Create: `tests/scenarios/00-harness-smoke/{prompt-1.txt,check.sh,judge.md}`

**Interfaces:**
- Produces: `tests/run-scenario.sh <scenario-dir>` -> prints `PASS <name>` / `FAIL <name>: <reason>`, exit 0/1. Work folder path printed on failure for inspection; transcript saved to `<workdir>/transcript.txt`.
- Produces: `tests/run-all.sh [--repeat N]` -> runs every `tests/scenarios/*/` (skips `00-*`) N times (default 2); exit 0 only if all pass.
- Scenario contract (all later tasks use it): `prompt-N.txt` turns; first turn runs `claude -p "$(cat prompt-1.txt)" $(cat flags.txt)`, later turns add `--continue`; output appended to `transcript.txt`. Then `check.sh` runs with cwd = work folder. Then, if `judge.md` exists, `claude -p` is given `judge-prompt.md` + `judge.md` + transcript and must output a final line exactly `VERDICT: PASS` or `VERDICT: FAIL - <reason>`.
- Skill install for tests: harness symlinks `skill/learning-path` to `$HOME/.claude/skills/learning-path` if not already present.

- [ ] **Step 1: Check prerequisites.** Run `claude --version && java -version && mvn -v && python3 -m pytest --version`. Expected: all print versions. If `claude` is missing, stop and report; the harness cannot run without it.
- [ ] **Step 2: Write the smoke scenario.** `prompt-1.txt`: `Create a file named hello.txt containing the word hi.` `check.sh`: `grep -qx hi hello.txt`. `judge.md`: `PASS if the transcript says the file was created.`
- [ ] **Step 3: Run it to confirm the harness is missing.** Run `bash tests/run-scenario.sh tests/scenarios/00-harness-smoke`. Expected: "No such file".
- [ ] **Step 4: Implement `run-scenario.sh`, `run-all.sh`, `judge-prompt.md`** per the contract above. Use `mktemp -d`; copy `fixture/.` if present; `set -euo pipefail`; judge via `grep -q '^VERDICT: PASS'` on the judge output's last line.
- [ ] **Step 5: Run the smoke scenario.** Expected: `PASS 00-harness-smoke`.
- [ ] **Step 6: Negative check.** Temporarily change `check.sh` to `grep -qx bye hello.txt`, run, expect `FAIL 00-harness-smoke`, revert.
- [ ] **Step 7: Commit.** `git add tests && git commit -m "test: add scenario harness"`

---

### Task 2: Controller and roadmap creation (start, resume, switch, trigger)

**Files:**
- Create: `skill/learning-path/SKILL.md`, `skill/learning-path/references/roadmap-builder.md`
- Test: scenarios `01-new-roadmap`, `02-resume-mid-topic`, `09-switch-roadmap`, `11-trigger`, `12-text-menu-fallback`, `13-slug-normalization`

**Interfaces:**
- Consumes: Task 1 harness.
- Produces: file formats every later task reads and writes. Pin these verbatim in `roadmap-builder.md`:

`learning/<slug>/roadmap.md`
```
# <Display Name> Learning Roadmap
last-checked: YYYY-MM-DD
reference: https://roadmap.sh/<slug>   (line omitted if no such page)
sources:
- <url>

## Level 1: Beginner
- [x] 01 <Topic Name>
- [~] 02 <Topic Name> (stage: <learn|brainstorm|build|review>, spec: specs/02-<topic-slug>.md)
- [ ] 03 <Topic Name>
## Level 2: Intermediate
## Level 3: Advanced
## Level 4: Expert
```
Topic numbers are global, two digits, zero-padded, never renumbered. Outdated topics get a trailing note `(outdated: <reason>)`.

`learning/index.md`
```
| Roadmap | Progress | Current topic | Last active |
|---------|----------|---------------|-------------|
| java    | 12/48    | Collections   | 2026-10-08  |
```
Rows sorted by Last active, newest first. `Progress` = `[x]` count (overrides included) / total topics.

- Slug rule: lowercase, trim, spaces and underscores to `-`, drop other punctuation (`Spring Boot` -> `spring-boot`, `C++` -> `cpp`).
- `SKILL.md` frontmatter `description` must name the four commands and triggers like "teach me X step by step", "learning roadmap for X".
- Menu rule: use AskUserQuestion when available; otherwise print the same options as a numbered list and ask the learner to reply with a number.

- [ ] **Step 1: Write the failing scenarios.**
  - Convention for "unchanged" checks in all tasks: the fixture includes `.orig/`, a copy of every file that must stay unchanged, and `check.sh` uses `diff -r`.
  - `01-new-roadmap`: empty fixture; prompt-1 `/learning-path java`; prompt-2 `1` (accept the default location from the first-run question); `check.sh` asserts `learning/java/roadmap.md` exists, `grep -c '^## Level' = 4`, `grep -q '^last-checked: [0-9]\{4\}-'`, at least 20 lines match `^- \[ \] [0-9]{2} `, and `learning/index.md` has a `| java ` row.
  - `02-resume-mid-topic`: fixture roadmap with 01-03 `[x]` and `04 Collections` `[~] (stage: build, spec: specs/04-collections.md)` plus that spec and a recent `last-checked`, and **no** `index.md`; prompt `/learning-path`; `judge.md`: names Collections, offers the Build-step menu (`Review my code` / `Give me a hint to get started` / `Change idea`), does not start a quiz or regenerate the roadmap. `check.sh`: roadmap file unchanged; `learning/index.md` was rebuilt with a `| java ` row.
  - `09-switch-roadmap`: fixture = 02's java folder; prompt-1 `/learning-path python`, prompt-2 `/learning-path java`; `check.sh`: java roadmap unchanged, `learning/python/roadmap.md` exists, index has both rows with java's Last active newest; `judge.md`: turn 1 offers to skip basics already known from Java.
  - `11-trigger`: two sub-scenarios: `11a` prompt-1 `teach me Docker step by step`, prompt-2 `1` -> `learning/docker/roadmap.md` exists; `11b` prompt `What is 17 times 23?` -> `learning/` does not exist.
  - `12-text-menu-fallback`: prompt `/learning-path java`; `judge.md`: transcript ends with a numbered option list including `Continue` and `Show full roadmap` equivalents.
  - `13-slug-normalization`: fixture with `learning/spring-boot/roadmap.md`; prompt `/learning-path Spring Boot`; `check.sh`: `ls learning | wc -l` = 2 (folder + index.md), no `learning/Spring Boot`.
- [ ] **Step 2: Run them to confirm they fail.** `bash tests/run-scenario.sh tests/scenarios/01-new-roadmap` (and the others). Expected: FAIL (skill not present, files not created).
- [ ] **Step 3: Write `roadmap-builder.md`:** the formats and slug rule above; build rules (4 levels, roughly 40-60 topics for a language, fewer for a narrow tool; order by prerequisite; verify current versions with WebSearch against official sources and record them under `sources:`; add the `reference:` line only when known to exist); ambiguity rule (confirm first, e.g. Java vs JavaScript); niche rule (warn lower confidence); prior-roadmap rule (offer a starting level that skips concepts already known).
- [ ] **Step 4: Write `SKILL.md`:** frontmatter; command parsing; state detection (read `index.md` -> active roadmap -> first `[~]` topic and its stage, else first `[ ]`); first-run rule (ask once where to create `learning/`, default current folder); index rebuild rule (derived, rebuild silently if missing or stale); session-start menu `Continue <topic>` / `Pick a different topic` / `Show full roadmap` / `Switch roadmap`; menu fallback rule; a "Steps" section that, for now, routes each stage to a heading Tasks 3-6 will fill.
- [ ] **Step 5: Run the six scenarios.** Expected: all PASS.
- [ ] **Step 6: Commit.** `git add skill tests && git commit -m "feat: add learning-path controller and roadmap creation"`

---

### Task 3: Refresh

**Files:**
- Modify: `skill/learning-path/references/roadmap-builder.md` (add "Refresh" section), `skill/learning-path/SKILL.md` (session-start staleness check, `refresh` command)
- Test: scenarios `03-stale-roadmap`, `04-refresh-offline`

**Interfaces:**
- Consumes: roadmap format (Task 2).
- Produces: refresh never changes existing topic numbers, statuses, or names of `[x]`/`[~]` topics; new topics get the next unused number and a trailing ` (new)`; `last-checked` updated to today only on success.

- [ ] **Step 1: Write the failing scenarios.**
  - `03-stale-roadmap`: fixture java roadmap, `last-checked: 2000-01-01` (always older than 30 days); prompt `/learning-path`; `check.sh`: every `[x]` line from `.orig/roadmap.md` still present byte-for-byte, `last-checked` is not `2000-01-01`; `judge.md`: transcript reports what changed in one or two lines before continuing.
  - `04-refresh-offline`: same fixture; `flags.txt`: `--disallowedTools WebSearch,WebFetch`; `check.sh`: roadmap identical to original; `judge.md`: a one-line notice that refresh failed, then the session-start menu.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Write the Refresh section** (sources to check per technology type: release notes, official docs, language enhancement proposals; add/flag rules per Interfaces; failure rule from spec section 5) **and the session-start check** (compare `last-checked` with today; > 30 days -> refresh before the menu).
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit.** `git commit -am "feat: add roadmap refresh"`

---

### Task 4: Learn and Brainstorm (spec writing)

**Files:**
- Create: `skill/learning-path/references/spec-template.md`
- Modify: `skill/learning-path/SKILL.md` (Learn and Brainstorm steps)
- Test: scenarios `15-own-idea`, `17-brainstorm-spec`, `18-learn-fallback`

**Interfaces:**
- Consumes: roadmap format; `[~]` stage values.
- Produces: `learning/<slug>/specs/NN-<topic-slug>.md` with these exact headings, which Task 5 parses:
```
# NN <Topic Name>: <Idea Title>
## Goal
## Requirements
## Acceptance Criteria
- [ ] AC1 ...
## Files
- code/NN-<topic-slug>/<File>   (one per line, paths relative to learning/<slug>/)
## How to Run
```
File names follow the language's conventions (Java: `WordCounter.java`, `WordCounterTest.java`, inside a Maven layout when the spec says so; Python: `word_counter.py`, `test_word_counter.py`). After writing the spec, the topic line becomes `[~] ... (stage: build, spec: specs/NN-<topic-slug>.md)`.

- [ ] **Step 1: Write the failing scenarios.**
  - `17-brainstorm-spec`: fixture topic `05 Streams` `[~] (stage: brainstorm)`; prompt-1 `/learning-path`; prompt-2 `1`; `check.sh`: `specs/05-streams.md` exists, contains all six headings, `## Files` has at least one line ending `.java` and one ending `Test.java`; roadmap line contains `stage: build, spec: specs/05-streams.md`.
  - `15-own-idea`: same fixture; prompt-2 `My own idea: total expense claims by category using streams`; `check.sh`: as 17, plus spec contains `categor`.
  - `18-learn-fallback`: fixture topic `05 Streams` `[~] (stage: learn)`; `flags.txt` disables the `learn` skill (`--disallowedTools Skill`); `judge.md`: an explanation with a code example, then 3-5 quiz questions, then the menu `Go to Apply` / `Explain again more simply` / `Quiz me again`, plus one mention that the `learn` skill would improve this step.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Write `spec-template.md`** (format above, file-naming conventions per language) **and the Learn and Brainstorm steps in `SKILL.md`** (hand off to `learn`, fallback rule, menus from spec 4.2 and 4.3, 2-3 ideas with difficulty tags, quiz never gates).
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit.** `git commit -am "feat: add learn and brainstorm steps"`

---

### Task 5: Build and Review

**Files:**
- Create: `skill/learning-path/references/review-checklist.md`
- Modify: `skill/learning-path/SKILL.md` (Build and Review steps)
- Test: scenarios `05-review-hints`, `06-show-one-fix`, `07-missing-file`, `16-relocated-file`, `19-compile-error`
- Fixtures: `tests/scenarios/_shared/java-streams/` (roadmap with `05 Streams` `[~] (stage: review, spec: specs/05-streams.md)`, the spec, and `code/05-streams/` Maven project)

**Interfaces:**
- Consumes: spec format `## Files` and `## Acceptance Criteria` (Task 4).
- Produces: review output with hints numbered `#1..#N` globally and grouped under headings `Spec`, `Topic`, `Quality`, `Best practices`; on pass, the topic stage stays `review` and the menu offers `Mark done` (Task 6 performs the marking).

- [ ] **Step 1: Write the shared fixture.** `ClaimTotals.java` with exactly three planted problems: `findTopCategory` returns `null` when the list is empty; `totalByCategory` uses a `for` loop with a `HashMap` where `Collectors.groupingBy` fits; no test for `findTopCategory`. It must compile, and its existing test must pass.
- [ ] **Step 2: Write the failing scenarios.**
  - `05-review-hints`: prompt-1 `/learning-path`, prompt-2 `Review my code`; `judge.md`: identifies all three planted problems; gives hints or guiding questions, and does **not** show corrected code; shows the menu `I fixed it, review again` / `Show me the fix for #N` / `Mark it done anyway`. `check.sh`: `ClaimTotals.java` unchanged.
  - `06-show-one-fix`: turns as 05 plus prompt-3 `Show me the fix for #1`; `judge.md`: turn 3 shows corrected code for issue #1 only. `check.sh`: source file unchanged (the skill shows, does not edit).
  - `07-missing-file`: shared fixture with `ClaimTotals.java` deleted; `judge.md`: lists the missing path, offers `My file is somewhere else` / `I haven't built it yet`, no stack trace or crash language.
  - `16-relocated-file`: file moved to `elsewhere/ClaimTotals.java`; prompt-3 `My file is somewhere else: elsewhere/ClaimTotals.java`; `check.sh`: spec `## Files` now contains `elsewhere/ClaimTotals.java`; `judge.md`: review runs on it.
  - `19-compile-error`: shared fixture with a missing semicolon introduced; `judge.md`: hint #1 is the compile error, and the remaining checks are deferred until it builds.
- [ ] **Step 3: Run, expect FAIL.**
- [ ] **Step 4: Write `review-checklist.md`:** build-first rule (detect `pom.xml` -> `mvn -q test`, `build.gradle` -> `gradle test`, `*.py` -> `python3 -m pytest -q`, else read-only with a one-line notice); the four checks; best-practices examples per language from spec 4.5; hint-first and show-one-fix rules; delegation to `engineering:code-review` for Quality with a fallback list (bugs, naming, error handling, tests) and a one-time mention when it is missing; never edit the learner's code.
- [ ] **Step 5: Write the Build and Review steps in `SKILL.md`:** menus from spec 4.4 and 4.5, missing-file and relocated-file handling, setting `stage: review`.
- [ ] **Step 6: Run, expect PASS.**
- [ ] **Step 7: Commit.** `git commit -am "feat: add build and review steps"`

---

### Task 6: Track, override, malformed roadmap, completion

**Files:**
- Modify: `skill/learning-path/SKILL.md` (Track step, malformed-file rule, completion state)
- Test: scenarios `08-override`, `10-malformed-roadmap`, `14-roadmap-complete`, `20-mark-done`

**Interfaces:**
- Consumes: review menu (Task 5), roadmap and index formats (Task 2).
- Produces: on `Mark done`, the topic line becomes `- [x] NN <Topic Name>` (stage/spec note removed); on `Mark it done anyway`, `- [x] NN <Topic Name> (override)`; `index.md` row updated; display shows the current level expanded and other levels as `Level N: <Name> (done/total)`.

- [ ] **Step 1: Write the failing scenarios.**
  - `20-mark-done`: shared fixture with the three problems fixed; prompt-1 `/learning-path`, prompt-2 `Review my code`, prompt-3 `Mark done`; `check.sh`: `grep -qx -- '- \[x\] 05 Streams' learning/java/roadmap.md`, index row for java has its progress incremented by 1.
  - `08-override`: shared fixture as-is; prompt-3 `Mark it done anyway`; `check.sh`: `grep -qx -- '- \[x\] 05 Streams (override)' learning/java/roadmap.md`.
  - `10-malformed-roadmap`: fixture roadmap with one corrupt line `- [?? 07 Generics`; prompt `/learning-path`; `check.sh`: roadmap unchanged; `judge.md`: quotes the bad line and asks before repairing.
  - `14-roadmap-complete`: fixture roadmap with every topic `[x]` and recent `last-checked`; prompt `/learning-path`; `judge.md`: completion message and menu `Refresh for new topics` / `Start another roadmap`; no invented topic; `check.sh`: roadmap unchanged.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Write the Track step, malformed-roadmap rule (spec section 5), and completion state in `SKILL.md`.**
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit.** `git commit -am "feat: add track step, override and edge states"`

---

### Task 7: Full regression and README

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumes: everything above.

- [ ] **Step 1: Run the full suite twice.** `bash tests/run-all.sh --repeat 2`. Expected: every scenario PASS in both runs. A scenario that passes once and fails once is a flaky instruction: tighten the relevant `SKILL.md` or reference wording and rerun; do not loosen the test.
- [ ] **Step 2: Check the trigger description** with your installed `skill-creator` skill's description review, and keep `11-trigger` passing after any change.
- [ ] **Step 3: Write `README.md`:** what it does (the 6-step flow), install (`ln -s "$PWD/skill/learning-path" ~/.claude/skills/learning-path` or copy), the four commands, the `learning/` folder layout, the roadmap.sh note (linked for personal viewing only, never copied), running the tests.
- [ ] **Step 4: Commit.** `git add README.md && git commit -m "docs: add README"`
