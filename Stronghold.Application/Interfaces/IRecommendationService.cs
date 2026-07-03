using Stronghold.Application.DTOs.Supplements;

namespace Stronghold.Application.Interfaces;

/// <summary>
/// Content-based sistem preporuke: slicnost preko kategorije, dobavljaca i recenzija.
/// Detalji algoritma: recommender-dokumentacija.md u rootu repozitorija.
/// </summary>
public interface IRecommendationService
{
    Task<List<RecommendedSupplementResponse>> GetForCurrentUserAsync();
}
