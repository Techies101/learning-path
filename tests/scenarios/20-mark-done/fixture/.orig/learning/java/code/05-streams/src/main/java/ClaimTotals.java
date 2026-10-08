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
