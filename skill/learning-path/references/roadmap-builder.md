# Roadmap builder

Rules for creating a roadmap and the exact file formats every step reads and writes. Refresh rules are in "Refreshing a roadmap" at the end.

## Slug rule

Folder name for a technology: lowercase, trim, spaces and underscores to `-`, drop all other punctuation, except `C++` becomes `cpp` (and `C#` becomes `csharp`).
Examples: `Spring Boot` -> `spring-boot`, `Node_JS` -> `node-js`, `C++` -> `cpp`.
Always compute the slug before looking for or creating a folder. Never create a folder with spaces or capitals.

## File formats

### `learning/<slug>/roadmap.md`

```
# <Display Name> Learning Roadmap
last-checked: YYYY-MM-DD
reference: https://roadmap.sh/<slug>   (line omitted if no such page)
sources:
- <url>

## Level 1: Beginner
- [x] 01 <Topic Name>
- [~] 02 <Topic Name> (stage: <learn|brainstorm|build|review>, spec: specs/02-<topic-slug>.md, folder: code/02-<topic-slug>/)
- [ ] 03 <Topic Name>
## Level 2: Intermediate
## Level 3: Advanced
## Level 4: Expert
```

- Before a spec exists, a topic at stage `learn` or `brainstorm` carries only the stage: `- [~] 02 <Topic Name> (stage: learn)` or `(stage: brainstorm)`. Brainstorm adds `spec:` and `folder:` when it moves the topic to `build`; from stage `build` on, all three are always present.
- Topic numbers are global across levels, two digits, zero-padded, and never renumbered.
- Markers: `[ ]` not started, `[~]` in progress, `[x]` done, `[x] (override)` done without passing review.
- Outdated topics get a trailing note `(outdated: <reason>)`. Topics added later get `(new)`. Never delete a topic.
- `last-checked` is today's date when the roadmap is built or successfully refreshed.

### `learning/index.md`

```
| Roadmap | Progress | Current topic | Last active |
|---------|----------|---------------|-------------|
| java    | 12/48    | Collections   | 2026-10-08  |
```

- Rows sorted by Last active, newest first.
- `Progress` = count of `[x]` lines (overrides included) / total topic lines.
- `Current topic` = the topic the learner is working on in that roadmap. Rule: keep the topic already named here if it is still `[~]` in the roadmap; otherwise the first `[~]` topic, else the first `[ ]` topic, else `done`. When the learner picks a topic (Continue, Pick a different topic, Next topic), set it to that topic. Other `[~]` topics are paused, not lost.
- `Last active` = today's date for the roadmap the learner is working with this session; for other roadmaps keep the date already in the index, else use that roadmap's `last-checked` date.
- It is derived. See SKILL.md for when to rebuild it.

## Building a new roadmap

1. **Ambiguity.** If the name could mean different technologies (Java vs JavaScript, Go vs Golang the game, Spark, Swift, ...), confirm which one before doing anything else.
2. **Prior roadmaps.** If other roadmaps exist under `learning/`, offer a starting level that skips concepts the learner already knows from them (for example: skip variables, control flow and collections basics when coming from Java to Python). Show it as a menu with these options: start at Level 1 / skip basics already known from `<other>` and start at Level 2 / show the topic list first. Topics skipped are marked `[x] (override)` only if the learner picks the skip option; otherwise leave all topics `[ ]`.
3. **Research.** Use WebSearch to verify the current stable versions and the official documentation of the technology. Record each official page used under `sources:`. Base topics on official documentation, not on copied third-party outlines.
4. **Topics.** Build 4 levels: Beginner, Intermediate, Advanced, Expert, headings exactly `## Level 1: Beginner` ... `## Level 4: Expert`.
   - A language or large framework: roughly 40-60 topics. A narrow tool (for example Docker, Git): fewer, but at least 20.
   - Order by prerequisite: nothing appears before the topic it depends on.
   - One topic is small enough to learn and build a tiny project for in one sitting.
   - Name topics concretely ("Collections: List, Set, Map"), not vaguely.
5. **Niche technologies.** If there is little official documentation, say so and warn the learner the roadmap is lower confidence before writing it.
6. **Reference line.** Add `reference: https://roadmap.sh/<slug>` only when you know that page exists. Never fetch, scrape or copy roadmap.sh content; the link is only for the learner to open.
7. **Write** `learning/<slug>/roadmap.md` with every topic `[ ]` and `last-checked:` set to today. Do not create `specs/` or `code/` yet.
8. **Update** `learning/index.md` (create it if missing).

## Refreshing a roadmap

Runs when the learner types `refresh`, or at session start when `last-checked` is more than 30 days before today. Use only WebSearch and WebFetch for the research. If neither works (tool unavailable, denied, errors, no usable results), do not try other ways to reach the web (no curl, wget or similar through Bash) and go to "Failure" below.

1. **Check sources.** Re-check the `sources:` pages and look for what changed since `last-checked`, by technology type:
   - Language or runtime: release notes of new versions, and the language's enhancement proposals (for example JEPs for Java, PEPs for Python).
   - Framework or library: release notes and migration guides, deprecation notices.
   - Tool or platform: official documentation changelog and new feature pages.
   Every refresh that finds something, including release notes or changelog pages, must append each official page it consulted that is not yet listed to `sources:` (keep existing entries). Never fetch, scrape or copy roadmap.sh.
2. **Add new topics.** For something important that the roadmap lacks, add a line `- [ ] NN <Topic Name> (new)` at the end of the fitting level (right after that level's last topic). `NN` is the next unused number: the highest number in the file plus one, two digits. Do not renumber anything.
3. **Flag outdated topics.** If a `[ ]` (not started) topic is deprecated or superseded, append ` (outdated: <short reason>)` to its line. Never delete a topic.
4. **Never touch existing progress.** Never edit the line of any `[x]` or `[~]` topic in any way, not even to flag it outdated; keep the order of existing lines. If an `[x]` or `[~]` topic is outdated, mention it only in the summary (step 6).
5. **Write once, on success.** Edit the file with the changes and new `sources:` entries, set `last-checked:` to today's date, then update `index.md` (Progress and Current topic may change). Do this only after the research succeeded. Nothing found to change is still a success: only `last-checked` changes.
6. **Report in one or two lines**, for example "Refreshed Java roadmap: added 2 topics (49 Virtual Threads, 50 Records), flagged 1 as outdated (23 Applets)." or "Refreshed Java roadmap: nothing changed (checked JDK 25 release notes)." The report is at most two short lines in total: no paragraph, no "Sources:" list, no notes about unreachable pages or untouched progress. The summary must name something concrete (a version, topics added or flagged, or what was checked); also mention outdated `[x]`/`[~]` topics here. Then continue with the session; a refresh never asks the learner anything and never interrupts the current step.

### Failure

If the refresh cannot complete, leave `roadmap.md` and `last-checked` exactly as they were and write nothing partial. Tell the learner in one line: "Could not refresh the roadmap (no web access); I will retry next session." Then continue the session as normal. When the learner typed `refresh`, same line, then show the session-start menu (or the Build menu if the current topic is at stage `build`).
