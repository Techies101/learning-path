# Spec template

One page per topic, written during Brainstorm to `learning/<slug>/specs/NN-<topic-slug>.md`. Use these headings exactly, in this order, spelled and capitalized as shown. The review step reads them, so none may be renamed, merged or left out.

```
# NN <Topic Name>: <Idea Title>
## Goal
<one or two sentences: what the learner builds and why it exercises the topic>
## Requirements
- <what the program must do, 3-6 short bullets>
## Acceptance Criteria
- [ ] AC1 <observable, testable behavior>
- [ ] AC2 ...
## Folder
code/NN-<topic-slug>/
## Suggested Names
- <MainClass>, <MainClass>Test
## How to Run
<the exact commands to build, run and test from inside the topic folder>
```

## Rules

- `NN` is the topic's two-digit number and `<Topic Name>` its name exactly as in `roadmap.md`. `<topic-slug>` is the slug rule applied to the topic name (`Streams` -> `streams`, `Collections: List, Set, Map` -> `collections-list-set-map`).
- Aim for 3-6 acceptance criteria. Each is one checkbox line, numbered `AC1`, `AC2`, ..., unchecked (`- [ ]`), and checkable by running the code or its tests. At least one covers an edge case (empty input, invalid value). At least one requires that the concept just learned is used.
- Keep the whole spec to one page. No implementation code in it.
- `## Folder` holds the one path line `code/NN-<topic-slug>/`, relative to `learning/<slug>/`, with nothing else on that line. If the folder already exists with other contents, still use that path (the folder is reused, see scaffold.md).
- `## Suggested Names` is guidance only; the review never fails on names. Follow the language's conventions:
  - Java: `WordCounter`, `WordCounterTest` (UpperCamelCase class names; classes live in `src/main/java`, tests in `src/test/java`)
  - Python: `word_counter.py`, `test_word_counter.py` (snake_case modules; source in `src/`, tests in `tests/`)
  - Other: the usual file and naming style of that language or tool.
- `## How to Run` matches the scaffold: Java `mvn test` to run the tests, and `mvn -q compile` then `java -cp target/classes <MainClass>` to run the program (Spring Boot: `mvn spring-boot:run`); Python `pytest`; other tools their standard commands.
