using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Reviews;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/reviews")]
[Authorize]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewsController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    /// <summary>Pregled recenzija + pretraga po korisniku ili suplementu (desktop i detalji proizvoda).</summary>
    [HttpGet]
    public async Task<ActionResult<PagedResult<ReviewResponse>>> GetPaged([FromQuery] ReviewSearch search)
    {
        return Ok(await _reviewService.GetPagedAsync(search));
    }

    [HttpPost("my")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<ReviewResponse>> CreateMine(ReviewCreateRequest request)
    {
        return Ok(await _reviewService.CreateMineAsync(request));
    }

    [HttpGet("my")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<List<ReviewResponse>>> GetMine()
    {
        return Ok(await _reviewService.GetMineAsync());
    }
}
