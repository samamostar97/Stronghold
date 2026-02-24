using Stronghold.Application.Features.Recommendations.DTOs;

namespace Stronghold.Application.IServices;

public interface IRecommendationService
{
    Task<List<RecommendationResponse>> GetRecommendationsAsync(int userId, int count = 6);
}
