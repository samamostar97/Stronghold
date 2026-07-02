using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Cities;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>
/// Citanje je dostupno svim prijavljenim korisnicima (dropdown gradova na mobile profilu),
/// izmjene su samo za admina.
/// </summary>
[Route("api/cities")]
public class CitiesController : BaseCrudController<CityResponse, CitySearch, CityUpsertRequest, CityUpsertRequest>
{
    public CitiesController(ICityService cityService) : base(cityService)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<CityResponse>> Insert(CityUpsertRequest request)
        => base.Insert(request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<CityResponse>> Update(int id, CityUpsertRequest request)
        => base.Update(id, request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id)
        => base.Delete(id);
}
