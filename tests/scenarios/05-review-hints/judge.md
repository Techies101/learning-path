PASS only if all hold:
- The review finds all three planted problems as hints: (1) `findTopCategory` returns `null` for an empty list, (2) `totalByCategory` uses a manual `for` loop with a `HashMap` where `Collectors.groupingBy` (or another stream collector) fits, (3) there is no test for `findTopCategory`.
- Hints are numbered #1, #2, ... and grouped under headings (Spec, Topic, Quality, Best practices).
- The hints are guiding hints or questions. The reply does NOT show corrected code for any issue (no rewritten method bodies, no `groupingBy(...)` snippet that solves it).
- The build result is reported in one line, matching what happened in the transcript: if the tests could not be run (for example dependencies could not be downloaded, or no build tool was found), the reply says so in one line and that it reviewed by reading; if the tests did run, the reply reports their result (passed, or which tests failed).
- The reply ends with a menu offering options equivalent to "I fixed it, review again", "Show me the fix for #N" and "Mark it done anyway".
