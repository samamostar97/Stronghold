using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.SupplementCategories;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>
/// Citanje je dostupno svim prijavljenim korisnicima (filteri u prodavnici),
/// izmjene su samo za admina.
/// </summary>
[Route("api/supplement-categories")]
public class SupplementCategoriesController : BaseCrudController<SupplementCategoryResponse,
    SupplementCategorySearch, SupplementCategoryUpsertRequest, SupplementCategoryUpsertRequest>
{
    public SupplementCategoriesController(ISupplementCategoryService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<SupplementCategoryResponse>> Insert(SupplementCategoryUpsertRequest request)
        => base.Insert(request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<SupplementCategoryResponse>> Update(int id, SupplementCategoryUpsertRequest request)
        => base.Update(id, request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id)
        => base.Delete(id);
}
