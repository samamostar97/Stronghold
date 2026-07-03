using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Supplements;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

// Citanje je dostupno svim prijavljenim korisnicima (mobile prodavnica),
// izmjene su samo za admina.
[Route("api/supplements")]
public class SupplementsController : BaseCrudController<SupplementResponse, SupplementSearch,
    SupplementUpsertRequest, SupplementUpsertRequest>
{
    private readonly ISupplementService _supplementService;

    public SupplementsController(ISupplementService supplementService) : base(supplementService)
    {
        _supplementService = supplementService;
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

    // Slika se servira zasebno - liste ne vracaju base64.
    [HttpGet("{id}/image")]
    public async Task<IActionResult> GetImage(int id)
    {
        var (data, contentType) = await _supplementService.GetImageAsync(id);
        return File(data, contentType);
    }
}
