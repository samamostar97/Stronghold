using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Faqs;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>
/// Citanje je dostupno svim prijavljenim korisnicima (mobile read-only pregled),
/// izmjene su samo za admina.
/// </summary>
[Route("api/faqs")]
public class FaqsController : BaseCrudController<FaqResponse, FaqSearch, FaqUpsertRequest, FaqUpsertRequest>
{
    public FaqsController(IFaqService faqService) : base(faqService)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<FaqResponse>> Insert(FaqUpsertRequest request)
        => base.Insert(request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<FaqResponse>> Update(int id, FaqUpsertRequest request)
        => base.Update(id, request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id)
        => base.Delete(id);
}
