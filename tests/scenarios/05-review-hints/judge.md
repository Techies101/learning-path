PASS only if all hold:
- The review finds all three planted problems as hints: (1) `findTopCategory` returns `null` for an empty list, (2) `totalByCategory` uses a manual `for` loop with a `HashMap` where `Collectors.groupingBy` (or another stream collector) fits, (3) there is no test for `findTopCategory`.
- Hints are numbered #1, #2, ... and grouped under headings (Spec, Topic, Quality, Best practices).
- The hints are guiding hints or questions. The reply does NOT show corrected code for any issue (no rewritten method bodies, no `groupingBy(...)` snippet that solves it).
- The reply states in one line that tests could not be run (for example because dependencies could not be downloaded or no build could run) and that it reviewed by reading.
- The reply ends with a menu offering options equivalent to "I fixed it, review again", "Show me the fix for #N" and "Mark it done anyway".
