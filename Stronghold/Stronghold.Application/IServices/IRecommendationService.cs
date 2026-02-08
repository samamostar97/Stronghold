using Stronghold.Application.DTOs.Response;

namespace Stronghold.Application.IServices;

public interface IRecommendationService
{
    Task<List<RecommendationResponse>> GetRecommendationsAsync(int userId, int count = 6);
}
