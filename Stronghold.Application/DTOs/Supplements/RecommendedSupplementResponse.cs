namespace Stronghold.Application.DTOs.Supplements;

/// <summary>Preporuceni proizvod sa OBJASNJENJEM zasto se preporucuje.</summary>
public class RecommendedSupplementResponse
{
    public SupplementResponse Supplement { get; set; } = null!;
    public string Reason { get; set; } = null!;
}
