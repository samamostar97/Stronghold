namespace Stronghold.Application.DTOs.Supplements;

// Preporuceni proizvod sa OBJASNJENJEM zasto se preporucuje.
public class RecommendedSupplementResponse
{
    public SupplementResponse Supplement { get; set; } = null!;
    public string Reason { get; set; } = null!;
}
