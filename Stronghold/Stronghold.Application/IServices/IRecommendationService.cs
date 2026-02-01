using Stronghold.Application.DTOs.UserDTOs;

namespace Stronghold.Application.IServices;

public interface IRecommendationService
{
    Task<List<RecommendationDTO>> GetRecommendationsAsync(int userId, int count = 6);
}
