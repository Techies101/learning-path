# Review checklist

Used by the Review step. The skill reviews; it never edits the learner's code, tests or build files.

## 1. Find the code

Read `folder:` from the topic's roadmap line and `## Acceptance Criteria` from the spec. Both paths are relative to `learning/<slug>/`. Source and test files are the files under the folder that are not build setup (Java `*.java`, Python `*.py`, other languages their source files), ignoring `target/`, `build/`, `.venv/`, `node_modules/`. Open every one of them.

## 2. Build first

Build before judging anything else, then read the code.

a. **Run the test command** from inside the folder: `pom.xml` -> `mvn -q test`; `build.gradle` or `build.gradle.kts` -> `gradle test`; `*.py` files -> `python3 -m pytest -q`. Prefer the project's wrapper when there is one: if `mvnw` (Maven) or `gradlew` (Gradle) exists in the folder or in a parent folder up to the `learning/` workspace root, run it by its path instead (for example `./mvnw -q test` or `../../gradlew test`); a wrapper counts as the tool being installed. If no build file or Python source exists, or the tool is not installed (and there is no wrapper), there is nothing to run: do NOT compile (no `javac`, no `py_compile`), do NOT print the dependency message from step d, skip steps b to d, say in one line "No build tool found, so I reviewed by reading only.", and go on to the four checks by reading.
b. **Classify a non-zero exit** (exit 0 means the tests pass: go on to the four checks).
   - Compile error: the output contains `COMPILATION ERROR`, `error:` with a file and line, `SyntaxError`, or `cannot find symbol`. Go to step c.
   - Resolution failure: the output contains `Could not resolve`, `could not be resolved`, `Could not transfer artifact`, `Name or service not known`, `Connection refused`, `Read timed out`, `PluginResolutionException`, `DependencyResolutionException`, or `ModuleNotFoundError` for a third-party package. Dependencies or plugins could not be downloaded: it says nothing about the learner's code. Go to step d.
   - Failing tests: `Tests run:` with failures, `AssertionError`, or pytest `FAILED`. Failing tests are hint #1, shown first under the heading `Build`: one hint naming each failing test and its assertion message. Then run the four checks as usual; their hints continue from #2.
   - No tests collected (for example pytest exit code 5, or "No tests were executed"): report "no tests found" as a finding under Quality, then run the four checks.
   - Anything else (a non-zero exit matching none of the above, for example Gradle failing for an unrelated reason): go to step d, but say in one line "The test command failed for an unclear reason: <its last error line>" instead of the dependency message.
c. **Compile error: hint #1.** A compile error becomes hint #1, shown first under the heading `Build`, with the file and line. The other checks are deferred until it builds: say so in one line and list no other hints.
d. **Offline compile** (resolution failure or unexplained failure only). Compile the main sources with the plain compiler, which needs no dependencies and writes nothing into the learner's folder. Java: `javac -d <a fresh temp dir> $(find src/main/java -name '*.java')`. Python: `PYTHONPYCACHEPREFIX="$(mktemp -d)" python3 -m py_compile <each source file>` (the prefix keeps `__pycache__` out of the folder).
   - Compiles: say in one line, for a resolution failure, "Tests could not be run because dependencies could not be downloaded, so I reviewed by reading."; for an unexplained failure, the unclear-reason line from step b. Then review by reading.
   - Fails only because of missing libraries: without a classpath, code that imports a library (for example Spring or JUnit in main sources) fails with errors that say nothing about the learner's code. An error is a missing-library error when it is `package <p> does not exist` for a package that no source file in the folder declares, or `cannot find symbol` for a type, annotation or static member imported from such a package (or used from one, such as an annotation from that package). If every error is of that kind, this is not a compile error and not a hint: say in one line "Dependencies unavailable, so the compile could not be verified; I reviewed by reading.", then review by reading.
   - Any other error (a syntax error, a type error, or a symbol missing from the folder's own sources): it is a real compile error in the learner's code, hint #1 as in step c. Name only those errors; leave out the missing-library ones.

Tests that pass are not proof the spec is met; keep checking.

## 3. The four checks

Hints are numbered `#1`, `#2`, ... globally across checks, in order, and grouped under these headings (skip a heading with no hints). `Build` comes first and holds only a compile error or failing tests from section 2:

| Heading | Question |
|---|---|
| Build | Does it compile, and do the tests pass? (from section 2) |
| Spec | Is each acceptance criterion (AC1, AC2, ...) met? Name the unmet AC in the hint. |
| Topic | Was the concept just learned used, and used correctly? |
| Quality | Bugs, naming, error handling, tests (see 4). |
| Best practices | Does the code follow the blocking idioms below for the learner's language version? |

Best practices come in two kinds. Check them against the language version in the build file.

**Blocking idioms.** A violation is a numbered hint under `Best practices` and blocks a pass:
- Java: `Optional` instead of returning `null` for "no result" (Java 8+); records for plain data carriers (Java 16+); the stream operation or collector the topic teaches instead of a hand-written loop that does the same job; try-with-resources for closeable resources (files, I/O streams, connections).
- Python: type hints on public functions; context managers (`with`) for files and other resources.
- Other languages: the equivalent core idioms of the version in use (how the language expresses "no value", plain data types, resource cleanup, and the API the topic teaches).

**Style idioms.** Never a numbered hint and never blocking; at most an Optional note (section 4b):
- Java: `var` for obvious local types, `List.of`/`Map.of`, pattern matching and `switch` expressions where the older form is correct, naming style.
- Python: PEP 8 formatting nits, naming style, f-strings, `pathlib`, comprehensions.

## 4. Quality: delegate when possible

If the `engineering:code-review` skill is available, invoke it with the Skill tool on the topic folder's source and test files for the Quality check and fold its findings into hints. If it is not available (not installed, errors, denied), run the checks yourself and mention once per session, in one line, "`engineering:code-review` is not installed; I ran the quality check myself." The fallback list is complete on its own:
- Bugs: wrong results, edge cases (empty input, `null`, zero, duplicates), off-by-one.
- Naming: unclear or misleading names, against the language's conventions (suggested names in the spec are guidance only; never fail on them).
- Error handling: swallowed exceptions, missing validation, returning `null` or magic values where an exception or empty result fits.
- Tests: every public behavior and edge case has a test; tests assert something.

## 4b. Blocking or optional

The review passes when there are no blocking findings. Blocking means: an unmet acceptance criterion; the topic concept missing or misused; a real bug (incorrect behavior for a plausible input, a compile error, a failing test); a public behavior required by the spec that has no test; or a violation of a blocking idiom from section 3 for the language version. Everything else (style idioms from section 3, defensive null checks the spec does not require, package naming, tie-break choices the spec leaves open, style preferences) is an Optional note: list at most 3 under the heading `Optional notes`, never numbered as hints, and they never block a pass. A review with only Optional notes passes: show them, then the pass menu.

## 5. Hints first

Each hint is a short guiding statement or question that points to where and why, not how. It never contains corrected code, a rewritten method or the name of the exact API call that solves it. Example: "#2 (Best practices) `totalByCategory` builds the map by hand in a loop. Is there a stream collector for grouping and summing?"

Then show the menu:

1. I fixed it, review again
2. Show me the fix for #N
3. Mark it done anyway

If there are no blocking findings, say what is good in a line or two, show any Optional notes, and show:

1. Mark done

## 6. Show one fix

`Show me the fix for #N` (the learner may name the number in the reply): show the corrected code for hint #N only, with a one or two line explanation, as a snippet the learner can apply themselves. Do not edit their file. Never show fixes for other hints. Then show the issues menu again.
