import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClaimTotals {

    public static Map<String, Double> totalByCategory(List<Claim> claims) {
        Map<String, Double> totals = new HashMap<>();
        for (Claim c : claims) {
            if (totals.containsKey(c.category())) {
                totals.put(c.category(), totals.get(c.category()) + c.amount());
            } else {
                totals.put(c.category(), c.amount());
            }
        }
        return totals;
    }

    public static String findTopCategory(List<Claim> claims) {
        Map<String, Double> totals = totalByCategory(claims);
        return totals.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);
    }
}
