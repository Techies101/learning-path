# learning-path skill: design spec

- **Date:** 2026-10-08
- **Status:** Draft, awaiting review
- **Scope:** Phase 1 (Claude Code skill with built-in menus). Phase 2 (custom interactive pane) is out of scope and gets its own spec later.

## 1. Purpose

A Claude Code skill that guides a learner through any technology, beginner to expert, one topic at a time:
learn the topic, apply it in a small project the learner builds themselves, get it reviewed, and track progress.

**Success looks like:** the learner opens Claude Code any day, runs `/learning-path`, and resumes exactly where they left off, with a roadmap that stays current.

**Origin:** started as a Java roadmap; generalized to any technology (Java, Python, Docker, etc.).

## 2. Decisions made

| Decision | Choice | Reason |
|---|---|---|
| Topic source | Claude generates the roadmap itself, verified against official sources via web search | roadmap.sh terms ban automated access and copying; generating works for any technology |
| roadmap.sh | Linked only, for the learner to view personally | Allowed by its license |
| Freshness | Auto-refresh when `last-checked` is older than 30 days, plus manual `/learning-path refresh` | Catches release cycles without slowing every session |
| Environment | Claude Code; progress and specs stored as files | Learner works in Claude Code |
| Brainstorm step | Lightweight: 2-3 ideas, learner picks one, one-page spec | Full brainstorming process is too heavy per topic |
| Review feedback | Hints first, fix only on request | Learning value without getting stuck |
| Completion gate | Topic is done only when review passes; learner may override | Honest progress record |
| Topic folder | The skill creates `code/NN-topic/` with build setup only (Java: Maven `pom.xml` + JUnit; Python: `pyproject.toml` + pytest); the learner writes all classes and tests | Skips repeated setup, keeps the real coding for the learner, guarantees the reviewer can run tests |
| Review target | The whole topic folder, not a fixed file list | Learner can add helper files freely |
| UI | Phase 1: built-in Claude Code menus (AskUserQuestion). Phase 2: custom pane | Proves the flow before investing in UI |

## 3. Building blocks

### 3.1 The skill (installed at `~/.claude/skills/learning-path/`)

| File | Single job |
|---|---|
| `SKILL.md` | Controller: parses the command, finds current state, runs the right step |
| `references/roadmap-builder.md` | Rules for building and refreshing a roadmap: levels, ordering, official sources, never removing completed topics |
| `references/spec-template.md` | One-page spec format: goal, requirements, acceptance criteria, topic folder, suggested main class and test names |
| `references/scaffold.md` | Build setup to create in each topic folder, per language |
| `references/review-checklist.md` | The four review checks and the hint-first rule |

### 3.2 Commands

| Command | Behavior |
|---|---|
| `/learning-path <technology>` | Start a new roadmap, or continue an existing one |
| `/learning-path` | Continue the most recently active roadmap (from `index.md`) |
| `/learning-path refresh` | Refresh the current roadmap now |
| `/learning-path status` | Show the roadmap and progress |

### 3.3 Learner workspace

```
learning/
  index.md              <- all roadmaps: progress, current topic, last active
  java/
    roadmap.md          <- single source of truth: topics, levels, status, stage
    specs/
      03-collections.md
    code/
      03-collections/   <- one folder per topic, created by the skill with build setup only
  python/
    roadmap.md
    specs/
    code/
```

- One folder per roadmap; switching technologies never touches another roadmap.
- `roadmap.md` holds both the topic list and progress, so no separate tracker can drift.
- Status markers: `[ ]` not started, `[~]` in progress, `[x]` done, `[x] (override)` marked done without passing review.
- An in-progress topic records its stage, spec and folder, e.g. `[~] 03 Collections (stage: build, spec: specs/03-collections.md, folder: code/03-collections/)`.
- `roadmap.md` header holds `last-checked: YYYY-MM-DD` and the list of sources used.
- Topics added by a refresh are marked `(new)`; outdated topics are flagged, never deleted.
- `index.md` is a derived summary and can be rebuilt from the roadmap folders at any time.

## 4. Flow

### 4.1 Session start
1. Read `index.md` and the active `roadmap.md`.
2. If `last-checked` is older than 30 days, refresh and report changes in one or two lines.
3. Show position, e.g. "Java, Level 2 (Intermediate), topic 12 of 48: Collections".
4. Resume at the recorded stage.
5. Menu: `Continue <topic>` / `Pick a different topic` / `Show full roadmap` / `Switch roadmap`.

When starting a new roadmap and the learner already has another one, offer a starting level that skips concepts they already know.

### 4.2 Learn
- Hand off to the `learn` skill: short explanation with a small code example, then a 3-5 question quiz.
- Menu: `Go to Apply` / `Explain again more simply` / `Quiz me again`.
- The quiz score is not a gate.

### 4.3 Brainstorm
- Suggest 2-3 ideas, one line each, with a difficulty tag.
- Menu: `Idea 1` / `Idea 2` / `Idea 3` (learner may type their own).
- Write `specs/NN-topic.md` from the template, including the topic folder and suggested main class and test names using the language's conventions (e.g. `WordCounter.java` + `WordCounterTest.java`; `word_counter.py` + `test_word_counter.py`). Names are guidance; the review does not fail on them.
- Create the topic folder `code/NN-topic/` with build setup only:
  - Java: `pom.xml` (Java version = the learner's installed JDK, else the current LTS; JUnit Jupiter latest stable, looked up at creation time) and empty `src/main/java/` and `src/test/java/`.
  - Python: `pyproject.toml` with pytest, and empty `src/` and `tests/`.
  - Other technologies: the minimal standard setup for that tool, or an empty folder if none exists.
  - No source classes or test files.
- If the folder already exists, never overwrite it; reuse it.
- Record `stage: build` and the folder in the roadmap.

### 4.4 Build
- The learner writes the code; the skill waits.
- Menu on return: `Review my code` / `Give me a hint to get started` / `Change idea`.

### 4.5 Review
Open every source and test file in the topic folder recorded in the roadmap. If a build tool is available, build and run tests first; a compile error becomes hint #1.

| Check | Question |
|---|---|
| Spec | Are all acceptance criteria met? |
| Topic | Was the concept just learned used, and used correctly? |
| Quality | Bugs, naming, error handling, tests (delegated to `engineering:code-review` when installed) |
| Best practices | Does the code follow current idioms for the language version (e.g. records, `Optional`, pattern matching in `switch` on Java 21+; type hints and PEP 8 in Python)? |

- Issues are listed as hints, grouped by check.
- Menu with issues: `I fixed it, review again` / `Show me the fix for #N` / `Mark it done anyway`.
- Menu when it passes: `Mark done`.
- "Show me the fix for #N" shows only that fix.

### 4.6 Track
- Mark the topic `[x]` (or `[x] (override)`), update `index.md`.
- Show the updated roadmap: current level expanded, other levels collapsed to a progress count.
- Menu: `Next topic` / `Stop for today`.

## 5. Error handling

Rule: never block learning; never silently overwrite the learner's files.

| Situation | Behavior |
|---|---|
| Topic folder missing, or has no source files, at review | Say which. Menu: `My folder is somewhere else` (update the folder in spec and roadmap) / `I haven't built it yet` |
| Code doesn't compile or tests fail | Report as hint #1 before other checks |
| No build tool installed | Review by reading only, and say so |
| Refresh fails | Keep roadmap, leave `last-checked` unchanged, one-line notice, retry next session |
| Ambiguous technology name | Confirm first (e.g. "Java or JavaScript?") |
| Niche technology with little official documentation | Warn the roadmap is lower confidence |
| Malformed `roadmap.md` | Read leniently; show the unreadable line; repair only after the learner agrees |
| `index.md` missing or out of date | Rebuild from roadmap folders |
| No `learning/` folder | Ask once where to create it (default: current folder) |
| `learn` skill not installed | Teach inline in the same format; mention once that `learn` improves this step |
| `engineering:code-review` not installed | Run the quality check from `review-checklist.md`; mention once |

## 6. Testing

Skill behavior is tested by running prepared scenarios against fixtures.

**Fixtures:** a Java roadmap with some topics done and one at `stage: build`; a roadmap with `last-checked` 40 days old; a Java file with three planted problems (returns `null` instead of `Optional`, a `for` loop where a stream fits, a missing test); a malformed `roadmap.md`.

| # | Scenario | Pass if |
|---|---|---|
| 1 | `/learning-path java` in an empty folder | Creates `learning/java/roadmap.md` with 4 levels and `index.md` |
| 2 | Resume mid-topic | Shows correct topic and jumps to Build |
| 3 | Stale roadmap | Auto-refreshes; completed topics untouched; new topics marked `(new)` |
| 4 | Refresh while offline | Keeps roadmap, one-line notice, continues |
| 5 | Review the planted file | Finds all 3 planted problems, as hints, not fixes |
| 6 | "Show me the fix for #1" | Shows only that fix |
| 7 | Topic folder has no source files | Says so and shows the menu |
| 8 | "Mark it done anyway" | Recorded as `[x] (override)` |
| 9 | Switch to Python and back | Each roadmap keeps its own progress; `index.md` correct |
| 10 | Malformed roadmap | Shows the problem line; asks before repairing |
| 11 | Trigger check | Activates on `/learning-path` and "teach me Docker step by step"; stays quiet on unrelated requests |

| 12 | Brainstorm creates the topic folder | Folder has `pom.xml` with JUnit and the empty `src/` folders, and no source files; roadmap records the folder |

**Success criteria:** all 12 scenarios pass, each run twice in fresh sessions. Scenarios may be run as evals with the `skill-creator` skill; details go in the implementation plan.

## 7. Out of scope (Phase 1)

- The custom interactive pane (Phase 2).
- Scraping or copying content from roadmap.sh or any other site.
- Grading or certificates.
- Syncing progress across machines (the learner can commit `learning/` to Git).
