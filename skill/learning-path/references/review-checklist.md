# Review checklist

Used by the Review step. The skill reviews; it never edits the learner's code, tests or build files.

## 1. Find the code

Read `folder:` from the topic's roadmap line and `## Acceptance Criteria` from the spec. Both paths are relative to `learning/<slug>/`. Source and test files are the files under the folder that are not build setup (Java `*.java`, Python `*.py`, other languages their source files), ignoring `target/`, `build/`, `.venv/`, `node_modules/`. Open every one of them.

## 2. Build first

Build before judging anything else, then read the code.

a. **Run the test command** from inside the folder: `pom.xml` -> `mvn -q test`; `build.gradle` or `build.gradle.kts` -> `gradle test`; `*.py` files -> `python3 -m pytest -q`. If no build file or Python source exists, or the tool is not installed, there is nothing to run: do NOT compile (no `javac`, no `py_compile`), do NOT print the dependency message from step d, skip steps b to d, say in one line "No build tool found, so I reviewed by reading only.", and go on to the four checks by reading.
b. **Classify a non-zero exit** (exit 0 means the tests pass: go on to the four checks).
   - Compile error: the output contains `COMPILATION ERROR`, `error:` with a file and line, `SyntaxError`, or `cannot find symbol`. Go to step c.
   - Resolution failure: the output contains `Could not resolve`, `could not be resolved`, `Could not transfer artifact`, `Name or service not known`, `Connection refused`, `Read timed out`, `PluginResolutionException`, `DependencyResolutionException`, or `ModuleNotFoundError` for a third-party package. Dependencies or plugins could not be downloaded: it says nothing about the learner's code. Go to step d.
   - Failing tests: `Tests run:` with failures, `AssertionError`, or pytest `FAILED`. Report them as findings under Quality, naming each failing test, then run the four checks.
   - No tests collected (for example pytest exit code 5, or "No tests were executed"): report "no tests found" as a finding under Quality, then run the four checks.
   - Anything else (a non-zero exit matching none of the above, for example Gradle failing for an unrelated reason): go to step d, but say in one line "The test command failed for an unclear reason: <its last error line>" instead of the dependency message.
c. **Compile error: hint #1.** A compile error becomes hint #1, shown first under `Build`, with the file and line. The other checks are deferred until it builds: say so in one line and list no other hints.
d. **Offline compile** (resolution failure or unexplained failure only). Compile the main sources with the plain compiler, which needs no dependencies. Java: `javac -d <a fresh temp dir> $(find src/main/java -name '*.java')`. Python: `python3 -m py_compile` on each source file. If that compile fails, the error is hint #1 as in step c. If it succeeds, say in one line: for a resolution failure, "Tests could not be run because dependencies could not be downloaded, so I reviewed by reading."; for an unexplained failure, the unclear-reason line from step b. Then review by reading.

Tests that pass are not proof the spec is met; keep checking.

## 3. The four checks

Hints are numbered `#1`, `#2`, ... globally across checks, in order, and grouped under these headings (skip a heading with no hints):

| Heading | Question |
|---|---|
| Spec | Is each acceptance criterion (AC1, AC2, ...) met? Name the unmet AC in the hint. |
| Topic | Was the concept just learned used, and used correctly? |
| Quality | Bugs, naming, error handling, tests (see 4). |
| Best practices | Does the code follow current idioms for the learner's language version? |

Best-practice examples (check against the version in the build file):
- Java 21+: records for plain data, `Optional` instead of returning `null`, pattern matching and `switch` expressions, streams and collectors instead of manual loops where they fit, `List.of`/`Map.of` for immutable collections, `var` for obvious local types.
- Python: type hints, PEP 8 naming and layout, f-strings, `pathlib`, `with` for resources, comprehensions.
- Other languages: the current idioms of the version in use.

## 4. Quality: delegate when possible

If the `engineering:code-review` skill is available, invoke it with the Skill tool on the topic folder's source and test files for the Quality check and fold its findings into hints. If it is not available (not installed, errors, denied), run the checks yourself and mention once per session, in one line, "`engineering:code-review` is not installed; I ran the quality check myself." The fallback list is complete on its own:
- Bugs: wrong results, edge cases (empty input, `null`, zero, duplicates), off-by-one.
- Naming: unclear or misleading names, against the language's conventions (suggested names in the spec are guidance only; never fail on them).
- Error handling: swallowed exceptions, missing validation, returning `null` or magic values where an exception or empty result fits.
- Tests: every public behavior and edge case has a test; tests assert something.

## 5. Hints first

Each hint is a short guiding statement or question that points to where and why, not how. It never contains corrected code, a rewritten method or the name of the exact API call that solves it. Example: "#2 (Best practices) `totalByCategory` builds the map by hand in a loop. Is there a stream collector for grouping and summing?"

Then show the menu:

1. I fixed it, review again
2. Show me the fix for #N
3. Mark it done anyway

If there are no issues, say what is good in a line or two and show:

1. Mark done

## 6. Show one fix

`Show me the fix for #N` (the learner may name the number in the reply): show the corrected code for hint #N only, with a one or two line explanation, as a snippet the learner can apply themselves. Do not edit their file. Never show fixes for other hints. Then show the issues menu again.
