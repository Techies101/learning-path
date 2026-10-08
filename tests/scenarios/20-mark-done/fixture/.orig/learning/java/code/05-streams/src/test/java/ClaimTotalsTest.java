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
