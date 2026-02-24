using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Recommendations.Queries;
using Stronghold.Application.Features.Recommendations.DTOs;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/user/recommendations")]
[Authorize]
public class RecommendationController : ControllerBase
{
    private readonly IMediator _mediator;

    public RecommendationController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<RecommendationResponse>>> GetRecommendations([FromQuery] int count = 6)
    {
        var recommendations = await _mediator.Send(new GetRecommendationsQuery { Count = count });
        return Ok(recommendations);
    }
}
