import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class ClaimTotalsTest {

    @Test
    void totalsAreSummedPerCategory() {
        List<Claim> claims = List.of(
                new Claim("travel", 100.0),
                new Claim("meals", 20.0),
                new Claim("travel", 50.0));
        Map<String, Double> totals = ClaimTotals.totalByCategory(claims);
        assertEquals(150.0, totals.get("travel"));
        assertEquals(20.0, totals.get("meals"));
    }
}
