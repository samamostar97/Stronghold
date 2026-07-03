using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Supplements;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>
/// Citanje je dostupno svim prijavljenim korisnicima (mobile prodavnica),
/// izmjene su samo za admina.
/// </summary>
[Route("api/supplements")]
public class SupplementsController : BaseCrudController<SupplementResponse, SupplementSearch,
    SupplementUpsertRequest, SupplementUpsertRequest>
{
    private readonly ISupplementService _supplementService;
    private readonly IRecommendationService _recommendationService;

    public SupplementsController(
        ISupplementService supplementService,
        IRecommendationService recommendationService) : base(supplementService)
    {
        _supplementService = supplementService;
        _recommendationService = recommendationService;
    }

    /// <summary>"Preporučeno za tebe" - content-based preporuke sa objasnjenjem.</summary>
    [HttpGet("recommended")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<List<RecommendedSupplementResponse>>> GetRecommended()
    {
        return Ok(await _recommendationService.GetForCurrentUserAsync());
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<SupplementResponse>> Insert(SupplementUpsertRequest request)
        => base.Insert(request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<SupplementResponse>> Update(int id, SupplementUpsertRequest request)
        => base.Update(id, request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id)
        => base.Delete(id);

    /// <summary>Slika se servira zasebno - liste ne vracaju base64.</summary>
    [HttpGet("{id}/image")]
    public async Task<IActionResult> GetImage(int id)
    {
        var (data, contentType) = await _supplementService.GetImageAsync(id);
        return File(data, contentType);
    }
}
