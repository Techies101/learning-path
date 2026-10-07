# Roadmap builder

Rules for creating a roadmap and the exact file formats every step reads and writes. Refresh rules are added in a later section ("Refreshing a roadmap").

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
- `Current topic` = the first `[~]` topic, else the first `[ ]` topic, else `done`.
- `Last active` = today's date for the roadmap the learner is working with this session; for other roadmaps keep the date already in the index, or if rebuilding with no index, use the roadmap file's modification date.
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
