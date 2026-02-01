using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/user/recommendations")]
[Authorize]
public class RecommendationController : UserControllerBase
{
    private readonly IRecommendationService _recommendationService;

    public RecommendationController(IRecommendationService recommendationService)
    {
        _recommendationService = recommendationService;
    }

    [HttpGet]
    public async Task<ActionResult<List<RecommendationDTO>>> GetRecommendations([FromQuery] int count = 6)
    {
        var userId = GetCurrentUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        var recommendations = await _recommendationService.GetRecommendationsAsync(userId.Value, count);
        return Ok(recommendations);
    }
}
