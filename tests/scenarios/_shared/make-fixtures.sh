#!/usr/bin/env bash
# Rebuilds the fixture/ and .orig/ of every scenario that uses _shared/java-streams.
# Single source of truth: _shared/java-streams/. Run from anywhere; commit the output.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCEN="$(dirname "$HERE")"
SRC="$HERE/java-streams"
CODE=learning/java/code/05-streams

# The "fixed" variant: all three planted problems resolved (Optional, collector, test).
write_fixed() { # <code dir>
  local m="$1/src/main/java" t="$1/src/test/java"
  cat > "$m/Claim.java" <<'JAVA'
import java.math.BigDecimal;

public record Claim(String category, BigDecimal amount) {}
JAVA
  cat > "$m/ClaimTotals.java" <<'JAVA'
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

public final class ClaimTotals {

    private ClaimTotals() {}

    public static Map<String, BigDecimal> totalByCategory(List<Claim> claims) {
        Objects.requireNonNull(claims, "claims");
        return claims.stream()
                .collect(Collectors.groupingBy(Claim::category,
                        Collectors.reducing(BigDecimal.ZERO, Claim::amount, BigDecimal::add)));
    }

    /** The category with the highest total; on a tie, the alphabetically first one. */
    public static Optional<String> findTopCategory(List<Claim> claims) {
        return totalByCategory(claims).entrySet().stream()
                .max(Map.Entry.<String, BigDecimal>comparingByValue()
                        .thenComparing(Map.Entry.comparingByKey(Comparator.reverseOrder())))
                .map(Map.Entry::getKey);
    }
}
JAVA
  cat > "$t/ClaimTotalsTest.java" <<'JAVA'
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class ClaimTotalsTest {

    private static Claim claim(String category, String amount) {
        return new Claim(category, new BigDecimal(amount));
    }

    @Test
    void totalsAreSummedPerCategory() {
        List<Claim> claims = List.of(
                claim("travel", "100.00"),
                claim("meals", "20.00"),
                claim("travel", "50.00"));
        Map<String, BigDecimal> totals = ClaimTotals.totalByCategory(claims);
        assertEquals(new BigDecimal("150.00"), totals.get("travel"));
        assertEquals(new BigDecimal("20.00"), totals.get("meals"));
    }

    @Test
    void totalsOfEmptyListAreEmpty() {
        assertTrue(ClaimTotals.totalByCategory(List.of()).isEmpty());
    }

    @Test
    void totalsRejectNullList() {
        assertThrows(NullPointerException.class, () -> ClaimTotals.totalByCategory(null));
    }

    @Test
    void topCategoryIsTheOneWithTheHighestTotal() {
        List<Claim> claims = List.of(
                claim("travel", "100.00"),
                claim("meals", "20.00"),
                claim("travel", "50.00"));
        assertEquals(Optional.of("travel"), ClaimTotals.findTopCategory(claims));
    }

    @Test
    void topCategoryOfASingleClaimIsItsCategory() {
        assertEquals(Optional.of("meals"), ClaimTotals.findTopCategory(List.of(claim("meals", "5.00"))));
    }

    @Test
    void topCategoryOnATieIsTheAlphabeticallyFirst() {
        List<Claim> claims = List.of(claim("travel", "30.00"), claim("meals", "30.00"));
        assertEquals(Optional.of("meals"), ClaimTotals.findTopCategory(claims));
    }

    @Test
    void topCategoryOfEmptyListIsEmpty() {
        assertEquals(Optional.empty(), ClaimTotals.findTopCategory(List.of()));
    }
}
JAVA
  local tmp; tmp="$(mktemp -d)"
  (cd "$1" && javac -d "$tmp" $(find src/main/java -name '*.java'))
  rm -rf "$tmp"
}

build() { # <scenario> <variation>
  local d="$SCEN/$1"
  rm -rf "$d/fixture"
  mkdir -p "$d/fixture"
  cp -a "$SRC/." "$d/fixture/"
  case "$2" in
    full) ;;
    empty) find "$d/fixture/$CODE" -name '*.java' -delete ;;
    relocated)
      mkdir -p "$d/fixture/learning/java/elsewhere"
      mv "$d/fixture/$CODE" "$d/fixture/learning/java/elsewhere/streams" ;;
    compile-error)
      sed -i 's/^\(        return totals\);/\1/' "$d/fixture/$CODE/src/main/java/ClaimTotals.java"
      grep -q '^        return totals$' "$d/fixture/$CODE/src/main/java/ClaimTotals.java" ;;
    fixed) write_fixed "$d/fixture/$CODE" ;;
  esac
  cp -a "$d/fixture" "$d/.orig.tmp" && mv "$d/.orig.tmp" "$d/fixture/.orig"
}

# Task 5 scenarios
build 05-review-hints full
build 06-show-one-fix full
build 07-empty-folder empty
build 16-relocated-folder relocated
build 19-compile-error compile-error

# Task 6 scenarios
build 20-mark-done fixed
build 08-override full
