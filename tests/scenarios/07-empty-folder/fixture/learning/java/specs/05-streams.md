# 05 Streams: Claim Totals
## Goal
Summarize a list of expense claims with the Streams API: total per category and the top category. Exercises grouping, mapping and reducing with streams.
## Requirements
- A `Claim` record holds a category and an amount.
- `ClaimTotals.totalByCategory` returns the total amount per category.
- `ClaimTotals.findTopCategory` returns the category with the highest total.
- Both methods work on any list of claims, including an empty one.
## Acceptance Criteria
- [ ] AC1 `totalByCategory` returns the summed amount for each category.
- [ ] AC2 `findTopCategory` returns the category with the highest total.
- [ ] AC3 `findTopCategory` on an empty list returns an empty result and does not throw.
- [ ] AC4 The totals are computed with the Streams API.
- [ ] AC5 Both methods are covered by unit tests.
## Folder
code/05-streams/
## Suggested Names
- ClaimTotals, ClaimTotalsTest
## How to Run
mvn test
